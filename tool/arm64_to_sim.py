#!/usr/bin/env python3
"""Rewrite arm64 iOS-device Mach-O object files as arm64 iOS-simulator objects.

The vendor PrinterSDK static library ships only `ios-arm64` (device) and
`ios-x86_64-simulator` slices, so it cannot link against an arm64 iOS
Simulator, which Xcode requires on Apple Silicon. The arm64 device and arm64
simulator ABIs are identical for this code; only the platform recorded in the
Mach-O load commands differs.

This script replaces each object's LC_VERSION_MIN_IPHONEOS (16 bytes) with an
LC_BUILD_VERSION (24 bytes) whose platform is PLATFORM_IOSSIMULATOR, inserting
the extra 8 bytes after the load commands and shifting every file offset in the
object accordingly.

Usage: arm64_to_sim.py <input.o> [<input.o> ...]   (patched in place)
"""

import struct
import sys

MH_MAGIC_64 = 0xFEEDFACF
LC_SEGMENT_64 = 0x19
LC_SYMTAB = 0x02
LC_DYSYMTAB = 0x0B
LC_VERSION_MIN_IPHONEOS = 0x25
LC_BUILD_VERSION = 0x32
PLATFORM_IOSSIMULATOR = 7
S_ZEROFILL = 0x1
S_THREAD_LOCAL_ZEROFILL = 0x12
S_GB_ZEROFILL = 0x0C
# Load commands laid out as `linkedit_data_command` (cmd, cmdsize, dataoff, datasize).
LINKEDIT_DATA_COMMANDS = {
    0x1D,  # LC_CODE_SIGNATURE
    0x1E,  # LC_SEGMENT_SPLIT_INFO
    0x26,  # LC_FUNCTION_STARTS
    0x29,  # LC_DATA_IN_CODE
    0x2B,  # LC_DYLIB_CODE_SIGN_DRS
    0x2E,  # LC_LINKER_OPTIMIZATION_HINT
    0x33,  # LC_DYLD_EXPORTS_TRIE
    0x34,  # LC_DYLD_CHAINED_FIXUPS
}

SHIFT = 8  # LC_BUILD_VERSION (24) - LC_VERSION_MIN_IPHONEOS (16)


def _u32(buf, off):
    return struct.unpack_from("<I", buf, off)[0]


def _bump_u32(buf, off, threshold):
    """Add SHIFT to the uint32 file offset at `off` when it points past the header."""
    value = _u32(buf, off)
    if value >= threshold:
        struct.pack_into("<I", buf, off, value + SHIFT)


def patch(path):
    data = bytearray(open(path, "rb").read())
    magic, _cputype, _cpusub, _filetype, ncmds, sizeofcmds = struct.unpack_from(
        "<IiiIII", data, 0
    )
    if magic != MH_MAGIC_64:
        raise SystemExit("%s: not a 64-bit Mach-O object (magic %#x)" % (path, magic))

    header_end = 32 + sizeofcmds
    version_min_off = None
    off = 32
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<II", data, off)
        if cmd == LC_BUILD_VERSION:
            # Already converted (or built with a modern toolchain): only the
            # platform needs to change.
            struct.pack_into("<I", data, off + 8, PLATFORM_IOSSIMULATOR)
            open(path, "wb").write(data)
            return False
        if cmd == LC_VERSION_MIN_IPHONEOS:
            version_min_off = off
        elif cmd == LC_SEGMENT_64:
            # segment_command_64: ... vmaddr(24) vmsize(32) fileoff(40)
            # filesize(48) maxprot(56) initprot(60) nsects(64) flags(68)
            filesize = struct.unpack_from("<Q", data, off + 48)[0]
            if filesize:
                fileoff = struct.unpack_from("<Q", data, off + 40)[0]
                if fileoff >= header_end:
                    struct.pack_into("<Q", data, off + 40, fileoff + SHIFT)
            nsects = _u32(data, off + 64)
            sect = off + 72
            for _ in range(nsects):
                sect_size = struct.unpack_from("<Q", data, sect + 40)[0]
                sect_type = _u32(data, sect + 64) & 0xFF
                is_zerofill = sect_type in (
                    S_ZEROFILL,
                    S_GB_ZEROFILL,
                    S_THREAD_LOCAL_ZEROFILL,
                )
                if sect_size and not is_zerofill:
                    _bump_u32(data, sect + 48, header_end)  # offset
                if _u32(data, sect + 60):  # nreloc
                    _bump_u32(data, sect + 56, header_end)  # reloff
                sect += 80
        elif cmd == LC_SYMTAB:
            if _u32(data, off + 12):  # nsyms
                _bump_u32(data, off + 8, header_end)  # symoff
            if _u32(data, off + 20):  # strsize
                _bump_u32(data, off + 16, header_end)  # stroff
        elif cmd == LC_DYSYMTAB:
            # (offset, count) pairs: toc, modtab, extrefsym, indirectsym,
            # extrel, locrel.
            for offset_off, count_off in (
                (32, 36), (40, 44), (48, 52), (56, 60), (64, 68), (72, 76)
            ):
                if _u32(data, off + count_off):
                    _bump_u32(data, off + offset_off, header_end)
        elif cmd in LINKEDIT_DATA_COMMANDS:
            if _u32(data, off + 12):  # datasize
                _bump_u32(data, off + 8, header_end)  # dataoff
        off += cmdsize

    if version_min_off is None:
        raise SystemExit("%s: no LC_VERSION_MIN_IPHONEOS to convert" % path)

    version, sdk = struct.unpack_from("<II", data, version_min_off + 8)
    build_version = struct.pack(
        "<IIIIII",
        LC_BUILD_VERSION,
        24,
        PLATFORM_IOSSIMULATOR,
        version,  # minos
        sdk,
        0,  # ntools
    )
    # Replacing 16 bytes with 24 grows the load-command region by exactly the
    # SHIFT that every file offset above was already moved by.
    data[version_min_off:version_min_off + 16] = build_version
    struct.pack_into("<I", data, 20, sizeofcmds + SHIFT)
    open(path, "wb").write(data)
    return True


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    for arg in sys.argv[1:]:
        patch(arg)
