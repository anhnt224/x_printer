/// Text alignment options for printing.
enum PTextAlign { left, center, right }

/// Text attributes for printing.
enum PTextAttribute { normal, fontB, bold, reverse, underline, underline2 }

/// Text width options for printing.
enum PTextW { w1, w2, w3, w4 }

/// Text height options for printing.
enum PTextH { h1, h2, h3, h4 }

/// String encoding options.
enum PStringEncoding { utf8, ascii, utf16 }

/// QR Code error correction levels.
enum QRErrLevel { L, M, Q, H }

/// Mapping of QR error correction levels to their respective values.
const errLevels = {
  QRErrLevel.L: 48,
  QRErrLevel.M: 49,
  QRErrLevel.Q: 50,
  QRErrLevel.H: 51,
};

/// Barcode types supported.
enum PBarcodeType {
  upcA,
  upcE,
  ean13,
  eab13,
  code39,
  itf,
  codabar,
  code93,
  code128
}

/// Represents the state of a peripheral device.
enum PeripheralState { disconnected, connected }

/// Represents a peripheral device.
class Peripheral {
  final String? name;
  final String? uuid;
  final int? stateStr;

  Peripheral({this.name, this.uuid, this.stateStr});

  /// Creates a [Peripheral] instance from a JSON map.
  factory Peripheral.fromJson(Map<String, dynamic> json) {
    return Peripheral(
      name: json['name'],
      uuid: json['uuid'],
      stateStr: json['state'],
    );
  }

  /// Gets the [PeripheralState] based on [stateCode].
  PeripheralState get state {
    switch (stateStr) {
      case 0:
        return PeripheralState.disconnected;
      case 2:
        return PeripheralState.connected;
      default:
        return PeripheralState.disconnected;
    }
  }
}

/// Represents the status of a printer.
class PrinterStatus {
  final int statusInt;
  final String? uuid;
  final String? statusMessage;

  PrinterStatus({required this.statusInt, this.uuid, this.statusMessage});

  /// Creates a [PrinterStatus] instance from a JSON map.
  factory PrinterStatus.fromJson(Map<String, dynamic> json) {
    return PrinterStatus(
      statusInt: json['status'],
      uuid: json['uuid'],
      statusMessage: json['statusMessage'],
    );
  }

  /// Gets the [PeripheralStatus] based on [statusCode].
  PeripheralStatus get status {
    switch (statusInt) {
      case 0:
        return PeripheralStatus.connecting;
      case 1:
        return PeripheralStatus.connected;
      case 2:
        return PeripheralStatus.disconnected;
      case 3:
        return PeripheralStatus.connectFailed;
      default:
        return PeripheralStatus.disconnected;
    }
  }
}

/// Represents the status of a peripheral device.
enum PeripheralStatus { connecting, connected, disconnected, connectFailed }
