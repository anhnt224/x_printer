import 'package:x_printer/printer_models.dart';

import 'bluetooth_printer_interface.dart';
export 'package:x_printer/printer_models.dart';

/// A class providing static methods to interact with XPrinter devices.
///
/// Offers functionality to scan for devices, connect, disconnect,
/// and send print commands to Bluetooth printers.
class XPrinter {
  /// Starts scanning for Bluetooth printers.
  Future<void> startScan() {
    return BluetoothPrinter.instance.startScan();
  }

  /// Stops scanning for Bluetooth printers.
  Future<void> stopScan() {
    return BluetoothPrinter.instance.stopScan();
  }

  /// Indicates whether scanning is in progress.
  Future<bool> get isScanning {
    return BluetoothPrinter.instance.isScanning();
  }

  /// Connects to a Bluetooth printer using its [uuid].
  Future<void> connect(String uuid) {
    return BluetoothPrinter.instance.connect(uuid);
  }

  /// Disconnects from the currently connected Bluetooth printer.
  Future<void> disconnect() {
    return BluetoothPrinter.instance.disconnect();
  }

  /// Prints [text] with specified formatting options.
  ///
  /// - [align] Text alignment (default is [PTextAlign.left]).
  /// - [attribute] Text attributes like bold or underline (default is [PTextAttribute.normal]).
  /// - [width] Text width multiplier (default is [PTextW.w1]).
  /// - [height] Text height multiplier (default is [PTextH.h1]).
  Future<void> printText(
    String text, {
    PTextAlign align = PTextAlign.left,
    PTextAttribute attribute = PTextAttribute.normal,
    PTextW width = PTextW.w1,
    PTextH height = PTextH.h1,
  }) {
    return BluetoothPrinter.instance.printText(
      text,
      align: align,
      attribute: attribute,
      width: width,
      height: height,
    );
  }

  /// Prints a QR code with the provided [code].
  ///
  /// - [unitSize] Size of the QR code units (default is 5).
  /// - [errLevel] Error correction level (default is [QRErrLevel.L]).
  /// - [encoding] String encoding used (default is [PStringEncoding.utf8]).
  Future<void> printQrCode(
    String code, {
    int unitSize = 5,
    QRErrLevel errLevel = QRErrLevel.L,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    return BluetoothPrinter.instance.printQrCode(
      code,
      unitSize: unitSize,
      errLevel: errLevel,
      encoding: encoding,
    );
  }

  /// Prints a barcode with the given [content].
  ///
  /// - [type] Type of the barcode (default is [PBarcodeType.code39]).
  /// - [encoding] String encoding used (default is [PStringEncoding.utf8]).
  Future<void> printBarcode(
    String content, {
    PBarcodeType type = PBarcodeType.code39,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    return BluetoothPrinter.instance.printBarcode(
      content,
      type: type,
      encoding: encoding,
    );
  }

  /// Prints an image from a base64 encoded string.
  ///
  /// - [base64Encoded] Base64 encoded image data.
  Future<void> printImage(
    String base64Encoded,
  ) {
    return BluetoothPrinter.instance.printImage(base64Encoded);
  }

  /// Checks if the printer is currently connected.
  Future<bool> get isConnected {
    return BluetoothPrinter.instance.isConnected;
  }

  /// Cuts the paper.
  Future<void> cutPaper() {
    return BluetoothPrinter.instance.cutPaper();
  }

  /// Stream providing status updates of the printer.
  Stream<PrinterStatus> get statusStream {
    return BluetoothPrinter.instance.statusStream;
  }

  /// Stream providing updates on discovered peripherals.
  Stream<List<Peripheral>> get peripheralsStream {
    return BluetoothPrinter.instance.peripheralsStream;
  }

  /// Stream indicating if the printer is scanning.
  Stream<bool> get isScanningStream {
    return BluetoothPrinter.instance.isScanningStream;
  }
}
