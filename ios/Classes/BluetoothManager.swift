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
    private var connectTimeoutTimer: DispatchSourceTimer?
    
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
    
    func connect(to uuid: String) {
        startConnectTimeoutTimer()
        statusMessage = "Connecting..."
        
        statusSink?([
            "status": PeripheralStatus.connecting.rawValue
        ])
        
        let peripheral = discoveredPeripherals.first(where: { $0.identifier.uuidString == uuid })
        
        if(peripheral == nil){
            statusSink?([
                "status": PeripheralStatus.connectFailed.rawValue,
                "uuid": uuid,
                "statusMessage": "Device not founded"
            ])
            return
        }
        
        posManager?.connectDevice(peripheral)
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
        invalidateConnectTimeoutTimer()
        statusMessage = "Failed to Connect: \(error.localizedDescription)"
        
        statusSink?([
            "status": PeripheralStatus.connectFailed.rawValue,
            "uuid": peripheral.identifier.uuidString,
            "statusMessage": error.localizedDescription
        ])
    }
    
    func poSbleDisconnectPeripheral(_ peripheral: CBPeripheral!, error: Error!) {
        invalidateConnectTimeoutTimer()
        statusMessage = "Disconnected"
        isConnected = false
        
        statusSink?([
            "status": PeripheralStatus.disconnected.rawValue,
            "uuid": peripheral.identifier.uuidString,
        ])
    }
    
    // MARK: - Timeout Handling
    private func startConnectTimeoutTimer() {
        invalidateConnectTimeoutTimer()
        
        connectTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        connectTimeoutTimer?.schedule(deadline: .now() + 10)
        
        connectTimeoutTimer?.setEventHandler { [weak self] in
            self?.handleConnectionTimeout()
        }
        
        connectTimeoutTimer?.resume()
    }
    
    private func invalidateConnectTimeoutTimer() {
        connectTimeoutTimer?.cancel()
        connectTimeoutTimer = nil
    }
    
    private func handleConnectionTimeout() {
        if !isConnected {
            statusMessage = "Connection Timed Out"
            statusSink?([
                "status": PeripheralStatus.connectFailed.rawValue,
                "statusMessage": "Connection timed out"
            ])
        }
    }
    
}
