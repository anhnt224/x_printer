import Flutter
import UIKit

public class XPrinterPlugin: NSObject, FlutterPlugin {
  let bluetoothManager = BluetoothManager()
    private var statusSink: FlutterEventSink?
    private var peripheralSink: FlutterEventSink?
    private var scanningSink: FlutterEventSink?
    private let invalidArgsError = FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "x_printer", binaryMessenger: registrar.messenger())
        let scanningChannel = FlutterEventChannel(name: "x_printer/scanning", binaryMessenger: registrar.messenger())
        let statusChannel = FlutterEventChannel(name: "x_printer/status", binaryMessenger: registrar.messenger())
        let peripheralChannel = FlutterEventChannel(name: "x_printer/peripheral", binaryMessenger: registrar.messenger())
        
        
        let instance = XPrinterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        statusChannel.setStreamHandler(StatusStreamHandler(bluetoothManager: instance.bluetoothManager))
        peripheralChannel.setStreamHandler(PeripheralStreamHandler(bluetoothManager: instance.bluetoothManager))
        scanningChannel.setStreamHandler(ScanningStreamHandler(bluetoothManager: instance.bluetoothManager))
        
        instance.bluetoothManager.statusSink = { (status: [String: Any]) in
            instance.statusSink?(status)
        }
        
        instance.bluetoothManager.peripheralSink = { (peripherals: [[String: Any?]]) in
            instance.peripheralSink?(peripherals)
        }
        
        instance.bluetoothManager.scanningSink = { (isScanning: Bool) in
            instance.scanningSink?(isScanning)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScan":
            bluetoothManager.startScanning()
            result(nil)
        case "stopScan":
            bluetoothManager.stopScanning()
            result(nil)
        case "isScanning":
            result(bluetoothManager.isScanning())
        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let deviceId = args["deviceId"] as? String
            else {
                result(invalidArgsError)
                return
            }
            
            let peripheral = bluetoothManager.discoveredPeripherals.first(where: { $0.identifier.uuidString == deviceId })
            if(peripheral == nil){
                result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found!", details: nil))
                return
            }
            
            bluetoothManager.connect(to: peripheral!)
            result(nil)
        case "printerIsConnect":
            result(bluetoothManager.printerIsConnect())
        case "printImage":
            guard let args = call.arguments as? [String: Any],
                  let data = args["data"] as? String else {
                result(invalidArgsError)
                return
            }
            
            printImage(base64Data: data, bluetoothManager: bluetoothManager)
            result(nil)
        case "printBarcode":
            guard let args = call.arguments as? [String: Any] else {
                result(invalidArgsError)
                return
            }
            
            printBarcode(bluetoothManager: bluetoothManager, attr: PBarCodeAttr.from(map: args))
        case "printQrCode":
            guard let args = call.arguments as? [String: Any] else {
                result(invalidArgsError)
                return
            }
            
            printQrCode(bluetoothManager: bluetoothManager, attr: PQrcodeAttr.from(map: args))
        case "printText":
            guard let args = call.arguments as? [String: Any] else {
                result(invalidArgsError)
                return
            }
            
            let text = args["text"] as? String ?? ""
            printText(text: text, args: args)
            result(nil)
        case "cutPaper":
            cutPaper(bluetoothManager: bluetoothManager)
        case "disconnect":
            bluetoothManager.disconnect()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func printText(text: String, args: [String: Any]){
        let attr = PTextAttr.from(map: args)
        var data = Data()
        data.append(POSCommand.initializePrinter())
        data.append(POSCommand.printText(text, alignment: attr.align, attribute: attr.attribute, textWid: attr.width, textHei: attr.height))
        
        bluetoothManager.sendCommand(data: data)
    }
    
    func printImage(base64Data: String, bluetoothManager: BluetoothManager) {
        let printMode: PrintRasterType = RasterNolmorWH
        let bmpType: BmpType = Dithering
        
        if let data = Data(base64Encoded: base64Data){
            let image = UIImage(data: data)
            
            var data = Data()
            data.append(POSCommand.initializePrinter())
            data.append(POSCommand.selectAlignment(1))
            data.append(POSCommand.printRasteBmp(withM: printMode, andImage: image, andType: bmpType))
            
            bluetoothManager.sendCommand(data: data)
        }
    }
    
    func cutPaper(bluetoothManager: BluetoothManager) {
        var data = Data()
        
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.printAndFeedLine())
        data.append(POSCommand.selectCutPageModelAndCutpage(1))
        
        bluetoothManager.sendCommand(data: data)
    }
    
    func printBarcode(bluetoothManager: BluetoothManager, attr: PBarCodeAttr) {
        var dataM = Data()
        dataM.append(POSCommand.initializePrinter())
        dataM.append(POSCommand.selectHRICharactersPrintPosition(2))
        dataM.append(POSCommand.selectAlignment(1))
        dataM.append(POSCommand.setBarcodeHeight(70))
        dataM.append(POSCommand.printBarcode(withM: attr.type, andContent: attr.content, useEnCodeing: attr.encoding))
        dataM.append(POSCommand.printAndFeedForwardWhitN(6))
        
        bluetoothManager.sendCommand(data: dataM as Data)
    }
    
    func printQrCode(bluetoothManager: BluetoothManager, attr: PQrcodeAttr){
        var data = Data()
        
        data.append(POSCommand.initializePrinter())
        data.append(POSCommand.selectAlignment(1))
        data.append(POSCommand.printQRCode(attr.unitSize, level: attr.errLevel, code: attr.code, useEnCodeing: attr.encoding))
        data.append(POSCommand.printAndFeedForwardWhitN(6))
        
        bluetoothManager.sendCommand(data: data)
    }
}
