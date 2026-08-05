# AGENTS.md

Guide for AI agents (and humans) updating this repo. `x_printer` is a Flutter
plugin that wraps BLE thermal-printer SDKs for Android (Kotlin) and iOS
(Swift) behind one Dart API.

## Layout

| Path | Purpose |
| --- | --- |
| `lib/x_printer.dart` | Public API (`XPrinter` class). What app code calls. |
| `lib/bluetooth_printer_interface.dart` | Abstract `BluetoothPrinter` contract, default `UnimplementedError` stubs. |
| `lib/bluetooth_printer_channel.dart` | `BluetoothPrinterChannel`: implements interface via `MethodChannel`/`EventChannel` named `x_printer`, `x_printer/status`, `x_printer/peripheral`, `x_printer/scanning`. |
| `lib/printer_models.dart` | Shared enums/models (`PTextAlign`, `PTextAttribute`, `PBarcodeType`, `PrinterStatus`, `Peripheral`, ...). |
| `android/src/main/kotlin/com/anhnt/x_printer/` | Android native impl: `XPrinterPlugin.kt` (channel handlers), `BleManager.kt` (BLE + printer SDK calls), `PosActivity.kt`, `models/PrinterModels.kt`. |
| `android/libs/printer-lib-3.2.0.jar` | Vendor printer SDK for Android. |
| `ios/x_printer/Sources/x_printer/` | iOS native impl: `XPrinterPlugin.swift`, `BluetoothManager.swift`, `Models/`, `StreamHandlers/` (one per event channel). |
| `ios/x_printer/Package.swift` | Swift Package Manager manifest. Target name must stay `x_printer`; library name `x-printer`. |
| `ios/x_printer/PrinterSDK.xcframework` | Vendor printer SDK for iOS (static lib, `ios-arm64` + `ios-x86_64-simulator`). |
| `ios/x_printer.podspec` | CocoaPods manifest. Must point at the same `x_printer/Sources/...` paths as SPM. |
| `example/` | Standalone Flutter app exercising the plugin — use it to manually test changes. |
| `CHANGELOG.md`, `pubspec.yaml` (`version:`) | Must be bumped together on every publishable change. |

## Core rule: keep the three sides in sync

Dart interface (`bluetooth_printer_interface.dart`) defines the contract.
`bluetooth_printer_channel.dart` forwards each method/stream to native code by
name. Android (`XPrinterPlugin.kt`) and iOS (`XPrinterPlugin.swift`) must each
handle the same method names and emit on the same event channel names.

When adding or changing a printer feature, update all of these, in order:

1. `lib/printer_models.dart` — add/adjust enums or models if needed.
2. `lib/bluetooth_printer_interface.dart` — add method/stream with doc comment and `UnimplementedError` stub.
3. `lib/x_printer.dart` — expose it on `XPrinter`, forwarding to `BluetoothPrinter.instance`.
4. `lib/bluetooth_printer_channel.dart` — wire it to `methodChannel.invokeMethod` (or an event channel) using a method name string.
5. `android/.../XPrinterPlugin.kt` + `BleManager.kt` — handle that method name, call vendor SDK.
6. `ios/x_printer/Sources/x_printer/XPrinterPlugin.swift` + `BluetoothManager.swift` — same, in Swift.
7. `example/lib/main.dart` (or `select_device.dart`) — add a usage example if it's a new user-facing feature.
8. `README.md` — update the feature table and usage snippet.
9. `CHANGELOG.md` + `pubspec.yaml` `version:` — bump together (see below).

Method/channel name strings are the contract between Dart and native —
grep all three sides (`grep -rn "methodName" lib android/src ios/Classes`)
before renaming one.

## Versioning

Follow pub.dev semver. Every change that ships adds a new top `## x.y.z`
section to `CHANGELOG.md` (newest first, short bullet list, same style as
existing entries) and bumps `version:` in `pubspec.yaml` to match. Don't bump
without a changelog entry or vice versa.

## Testing / verification

There is no Dart unit test suite in `lib/` (`mockito`/`flutter_lints` are
dev deps but unused for now) and no CI config in this repo. Verify changes
manually:

- `flutter analyze` from repo root — must stay clean (`analysis_options.yaml` uses `flutter_lints`).
- Android native: `android/src/test/kotlin/.../XPrinterPluginTest.kt` has unit tests — run via the Android Gradle test task if touching Kotlin.
- iOS native: both dependency managers must keep working, so build `example/` twice:

  ```bash
  flutter config --enable-swift-package-manager
  cd example && flutter build ios --no-codesign --debug

  flutter config --no-enable-swift-package-manager
  cd example && rm -rf ios/Pods ios/Podfile.lock && flutter build ios --no-codesign --debug
  ```

- Manual end-to-end: run `example/` on a real device against an actual BLE printer — this plugin only works against real hardware, there's no simulator/mock BLE path.

## Native SDK constraints

Printing logic is bounded by the vendor SDKs (`android/libs/printer-lib-3.2.0.jar`,
`ios/x_printer/PrinterSDK.xcframework`), which are prebuilt binaries, not source —
don't try to edit them. Check their bundled headers (inside the xcframework's
`Headers/`) before assuming a capability doesn't exist.

The iOS SDK ships no arm64 iOS Simulator slice, so simulator builds on Apple
Silicon fail to link. Build for a physical device when verifying iOS changes.

Swift sources reach the ObjC SDK through two different module layouts: under
SPM it is a separate `PrinterSDK` module, under CocoaPods its headers are
merged into the pod's own module. That is why the Swift files guard the import
with `#if canImport(PrinterSDK)`. Keep that guard on any new file that touches
`POS*` / `PTable` types.

## Platform permissions

BLE requires Bluetooth + Location permissions on both platforms (see README's
"Add permissions for Bluetooth" section). If a change touches scanning/connect
flow, check whether README's permission instructions still match
`android/src/main/AndroidManifest.xml` and `example/ios/Runner/Info.plist`.
