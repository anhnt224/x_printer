//
//  PeripheralStreamHandler.swift
//  x_printer
//
//  Created by AnhNT on 4/11/24.
//

import Flutter


class PeripheralStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        bluetoothManager.peripheralSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothManager.peripheralSink = nil
        return nil
    }
    
    private let bluetoothManager: BluetoothManager
    
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
    }
}
