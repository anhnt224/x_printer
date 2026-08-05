//
//  BleStatusStreamHandler.swift
//  x_printer
//
//  Created by AnhNT 4/11/24.
//

import Flutter

class StatusStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        bluetoothManager.statusSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothManager.statusSink = nil
        return nil
    }
    
    private let bluetoothManager: BluetoothManager
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
    }
}
