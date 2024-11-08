import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:x_printer/bluetooth_printer_interface.dart';
import 'package:x_printer/printer_models.dart';

/// A channel-based implementation of [BluetoothPrinter] interface.
///
/// This class communicates with the native platform using method channels
/// to perform Bluetooth printer operations.
class BluetoothPrinterChannel extends BluetoothPrinter {
  /// Method channel for invoking platform-specific methods.
  @visibleForTesting
  final methodChannel = const MethodChannel('x_printer');

  /// Event channel for receiving printer status updates.
  @visibleForTesting
  final statusChannel = const EventChannel('x_printer/status');

  /// Event channel for receiving peripheral device updates.
  @visibleForTesting
  final peripheralChannel = const EventChannel('x_printer/peripheral');

  /// Event channel for receiving scanning status updates.
  @visibleForTesting
  final scanningChannel = const EventChannel('x_printer/scanning');

  /// Starts scanning for Bluetooth peripherals.
  @override
  Future<void> startScan() async {
    await methodChannel.invokeMethod<void>('startScan');
  }

  /// Stops scanning for Bluetooth peripherals.
  @override
  Future<void> stopScan() async {
    await methodChannel.invokeMethod<void>('stopScan');
  }

  /// Connects to a Bluetooth peripheral with the given [uuid].
  @override
  Future<void> connect(String uuid) async {
    await methodChannel.invokeMethod<void>('connect', {"deviceId": uuid});
  }

  /// Checks if scanning is in progress.
  @override
  Future<bool> isScanning() async {
    return await methodChannel.invokeMethod("isScanning") ?? false;
  }

  /// Disconnects from the currently connected Bluetooth peripheral.
  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  /// Checks if there is an active connection to a Bluetooth peripheral.
  @override
  Future<bool> get isConnected async {
    final connected =
        await methodChannel.invokeMethod<bool>('printerIsConnect') ?? false;
    return connected;
  }

  /// Sends a text to be printed by the printer.
  ///
  /// Parameters:
  /// - [text] The text content to print.
  /// - [align] Text alignment (default is [PTextAlign.left]).
  /// - [attribute] Text attribute like bold or underline.
  /// - [width] Text width multiplier.
  /// - [height] Text height multiplier.
  @override
  Future<void> printText(
    String text, {
    PTextAlign align = PTextAlign.left,
    PTextAttribute attribute = PTextAttribute.normal,
    PTextW width = PTextW.w1,
    PTextH height = PTextH.h1,
  }) async {
    final args = {
      'text': text,
      'align': align.index,
      'attribute': attribute.index,
      'width': width.index,
      'height': height.index,
    };

    await methodChannel.invokeMethod<void>('printText', args);
  }

  /// Prints a barcode with the specified content.
  ///
  /// Parameters:
  /// - [content] The content to encode in the barcode.
  /// - [type] Type of the barcode (default is [PBarcodeType.ean13]).
  /// - [encoding] String encoding used (default is [PStringEncoding.utf8]).
  @override
  Future<void> printBarcode(
    String content, {
    PBarcodeType type = PBarcodeType.eab13,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    final args = {
      'content': content,
      'type': type.index,
      'encoding': encoding.index,
    };

    return methodChannel.invokeMethod<void>('printBarcode', args);
  }

  /// Prints a QR code with the given data.
  ///
  /// Parameters:
  /// - [code] The data to encode in the QR code.
  /// - [unitSize] Size of the QR code units.
  /// - [errLevel] Error correction level.
  /// - [encoding] String encoding used.
  @override
  Future<void> printQrCode(
    String code, {
    int unitSize = 5,
    QRErrLevel errLevel = QRErrLevel.L,
    PStringEncoding encoding = PStringEncoding.utf8,
  }) {
    final args = {
      'code': code,
      'unitSize': unitSize,
      'errLevel': errLevels[errLevel],
      'encoding': encoding.index,
    };

    return methodChannel.invokeMethod<void>('printQrCode', args);
  }

  /// Prints an image from a base64 encoded string.
  ///
  /// Parameters:
  /// - [base64Encoded] The base64 encoded image data.
  @override
  Future<void> printImage(String base64Encoded, double width) async {
    await methodChannel.invokeMethod<void>(
        'printImage', {'data': base64Encoded, 'width': width});
  }

  /// Sends a command to cut the paper.
  @override
  Future<void> cutPaper() async {
    await methodChannel.invokeMethod<void>('cutPaper');
  }

  /// Stream of [PrinterStatus] updates from the printer.
  @override
  Stream<PrinterStatus> get statusStream {
    return statusChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event ?? {});
      return PrinterStatus.fromJson(map);
    });
  }

  /// Stream of lists of available [Peripheral] devices.
  @override
  Stream<List<Peripheral>> get peripheralsStream {
    return peripheralChannel.receiveBroadcastStream().map((event) {
      final maps = _convertToListMap(event);
      return maps.map((map) => Peripheral.fromJson(map)).toList();
    });
  }

  /// Stream indicating the scanning status.
  @override
  Stream<bool> get isScanningStream {
    return scanningChannel
        .receiveBroadcastStream()
        .map((event) => event == true);
  }

  /// Converts a list of dynamic objects to a list of maps.
  ///
  /// Parameters:
  /// - [list] The list to convert.
  List<Map<String, dynamic>> _convertToListMap(List<Object?> list) {
    return list
        .whereType<Map>() // Filter out non-Map objects
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
