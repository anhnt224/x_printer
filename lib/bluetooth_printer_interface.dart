import 'package:x_printer/bluetooth_printer_channel.dart';
import 'package:x_printer/printer_models.dart';

/// Abstract class defining the Bluetooth printer interface.
abstract class BluetoothPrinter {
  BluetoothPrinter();

  /// Singleton instance of [BluetoothPrinter].
  static final BluetoothPrinter _instance = BluetoothPrinterChannel();

  /// Provides access to the singleton instance.
  static BluetoothPrinter get instance => _instance;

  /// Starts scanning for Bluetooth devices.
  Future<void> startScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  /// Stops scanning for Bluetooth devices.
  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  /// Checks if the printer is currently scanning.
  Future<bool> isScanning() {
    throw UnimplementedError('isScanning() has not been implemented.');
  }

  /// Connects to a Bluetooth device with the given [uuid].
  Future<void> connect(String uuid) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  /// Disconnects from the currently connected Bluetooth device.
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Checks if a device is currently connected.
  Future<bool> get isConnected {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Prints the provided [text] with specified formatting options.
  ///
  /// - [align] Alignment of the text.
  /// - [attribute] Text attributes like bold or underline.
  /// - [width] Text width multiplier.
  /// - [height] Text height multiplier.
  Future<void> printText(
    String text, {
    PTextAlign align = PTextAlign.left,
    PTextAttribute attribute = PTextAttribute.normal,
    PTextW width = PTextW.w1,
    PTextH height = PTextH.h1,
  }) {
    throw UnimplementedError('printText() has not been implemented.');
  }

  /// Prints a QR code with the given [code].
  ///
  /// - [unitSize] Size of the QR code units.
  /// - [errLevel] Error correction level.
  /// - [encoding] String encoding used.
  Future<void> printQrCode(
    String code, {
    int unitSize = 5,
    QRErrLevel errLevel = QRErrLevel.L,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    throw UnimplementedError('printQrCode() has not been implemented.');
  }

  /// Prints a barcode with the given [content].
  ///
  /// - [type] Type of barcode.
  /// - [encoding] String encoding used.
  Future<void> printBarcode(
    String content, {
    PBarcodeType type = PBarcodeType.code39,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    throw UnimplementedError('printBarcode() has not been implemented.');
  }

  /// Prints an image from a base64 encoded string.
  ///
  /// - [base64Encoded] The base64 encoded image data.
  Future<void> printImage(String base64Encoded) {
    throw UnimplementedError('printImage() has not been implemented.');
  }

  /// Cuts the paper.
  Future<void> cutPaper() {
    throw UnimplementedError('cutPaper() has not been implemented.');
  }

  /// Stream indicating if the printer is scanning.
  Stream<bool> get isScanningStream {
    throw UnimplementedError('isScanningStream() has not been implemented.');
  }

  /// Stream providing status updates of the printer.
  Stream<PrinterStatus> get statusStream {
    throw UnimplementedError('statusUpdates() has not been implemented.');
  }

  /// Stream providing updates on discovered peripherals.
  Stream<List<Peripheral>> get peripheralsStream {
    throw UnimplementedError('peripheralUpdates() has not been implemented.');
  }
}
