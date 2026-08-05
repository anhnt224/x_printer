//
//  ScanningStreamHandler.swift
//  x_printer
//
//  Created by Trọng Ánh Nhâm on 2/11/24.
//

import Flutter

class ScanningStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        bluetoothManager.scanningSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothManager.scanningSink = nil
        return nil
    }
    
    private let bluetoothManager: BluetoothManager
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
    }
}
