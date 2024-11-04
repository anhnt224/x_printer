//
//  BluetoothManager.swift
//  x_printer
//
//  Created by AnhNT on 4/11/24.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, POSBLEManagerDelegate {
    
    var scanningSink: ((Bool) -> Void)?
    var statusSink: (([String: Any]) -> Void)?
    var peripheralSink: (([[String: Any?]]) -> Void)?
    
    var discoveredPeripherals: [CBPeripheral] = []
    var isConnected: Bool = false
    var statusMessage: String = "Disconnected"
    var printerStatusMessage: String = ""
    var printerSN: String = ""
    
    private let posManager = POSBLEManager.sharedInstance()
    
    override init() {
        super.init()
        posManager?.delegate = self
        
        if(posManager?.isScaning == true){
            scanningSink?(true)
        }else{
            scanningSink?(false)
        }
    }
    
    func startScanning() {
        posManager?.startScan()
        scanningSink?(true)
    }
    
    func stopScanning() {
        posManager?.stopScan()
        scanningSink?(false)
    }
    
    func connect(to peripheral: CBPeripheral) {
        posManager?.connectDevice(peripheral)
        statusMessage = "Connecting..."

        statusSink?([
            "status": PeripheralStatus.connecting.rawValue
        ])
    }
    
    func disconnect() {
        posManager?.disconnectRootPeripheral()
        statusMessage = "Disconnected"
        isConnected = false
        
        statusSink?([
            "status": PeripheralStatus.disconnected.rawValue
        ])
    }
    
    func printerIsConnect() -> Bool {
        return posManager?.printerIsConnect() ?? false
    }
    
    func isScanning() -> Bool {
        return posManager?.isScaning ?? false
    }
    
    func sendCommand(data: Data) {
        posManager?.writeCommand(with: data)
    }
    
    // MARK: - POSBLEManagerDelegate Methods
    
    func poSbleUpdatePeripheralList(_ peripherals: [Any]!, rssiList: [Any]!) {
        guard let discoveredPeripherals = peripherals as? [CBPeripheral] else { return }
        self.discoveredPeripherals = discoveredPeripherals
        
        peripheralSink?(discoveredPeripherals.map({ e in
            e.toDict()
        }))
        print(">>> \(discoveredPeripherals)")
    }
    
    func poSbleConnect(_ peripheral: CBPeripheral!) {
        statusMessage = "Connected to \(peripheral.name ?? "Unknown Device")"
        isConnected = true
        
        statusSink?([
            "status": PeripheralStatus.connected.rawValue,
            "uuid": peripheral.identifier.uuidString
        ])
    }
    
    func poSbleFail(toConnect peripheral: CBPeripheral!, error: Error!) {
        statusMessage = "Failed to Connect: \(error.localizedDescription)"
        
        statusSink?([
            "status": PeripheralStatus.connectFailed.rawValue,
            "uuid": peripheral.identifier.uuidString,
            "statusMessage": error.localizedDescription
        ])
    }
    
    func poSbleDisconnectPeripheral(_ peripheral: CBPeripheral!, error: Error!) {
        statusMessage = "Disconnected"
        isConnected = false
        
        statusSink?([
            "status": PeripheralStatus.disconnected.rawValue,
            "uuid": peripheral.identifier.uuidString,
        ])
    }
    
}
