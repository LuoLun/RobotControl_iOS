//
//  BluetoothManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate: class {
    func bluetoothManagerDidUpdateState(_ state: CBManagerState)
    func bluetoothManagerdidUpdateDeviceList(_ deviceList: Set<CBPeripheral>)
    func bluetoothManagerFinishConnection(to device: CBPeripheral, success: Bool, error: Error?)
    func bluetoothManagerDidDisconnection(to device: CBPeripheral, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    
    var uuid: String {get}
}

class BluetoothManager: NSObject {
    
    var _delegates = Array<BluetoothManagerDelegate>()
    
    let _centralManager: CBCentralManager
    
    var _devices = Set<CBPeripheral>()
    var _connectedDevice: CBPeripheral?
    
    public static let sharedInstance = BluetoothManager()
    
    override private init() {
        _centralManager = CBCentralManager()
        super.init()
        
        _centralManager.delegate = self
    }
    
    func showAllDevices() {
        if _centralManager.state == .poweredOn {
            _devices.removeAll()
            _centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func connectionToDevice(device: CBPeripheral) {
        _centralManager.connect(device, options: nil)
    }
    
    func send(data: Data) -> Bool {
        // 向所有服务和characteristic发送数据。等需要接入真正的设备的时候，这里需要进行筛选
        guard let services = _connectedDevice?.services else {
            return false
        }
        
        for service in services {
            guard let characteristics = service.characteristics else {
                return false
            }
            
            for characteristic in characteristics {
                _connectedDevice?.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
        
        return true
    }
    
    func add(delegate: BluetoothManagerDelegate) {
        _delegates.append(delegate)
    }
    
    func remove(delegate: BluetoothManagerDelegate) {
        let index = _delegates.index(where: { $0.uuid == delegate.uuid })!
        _delegates.remove(at: index)
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        _delegates.forEach { $0.bluetoothManagerDidUpdateState(central.state) }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        _devices.insert(peripheral)
        _delegates.forEach { $0.bluetoothManagerdidUpdateDeviceList(_devices) }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _connectedDevice = peripheral
        _connectedDevice?.delegate = self
        _delegates.forEach { $0.bluetoothManagerFinishConnection(to: peripheral, success: true, error: nil) }
        
        discoverServicesForConnectedPeripheral()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        _delegates.forEach { $0.bluetoothManagerFinishConnection(to: peripheral, success: false, error: error) }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        _connectedDevice?.delegate = nil
        _connectedDevice = nil
        _delegates.forEach { $0.bluetoothManagerDidDisconnection(to: peripheral, error: error) }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print(error)
        }
        
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print(error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        _delegates.forEach { $0.peripheral(peripheral, didWriteValueFor: characteristic, error: error) }
    }
    
}

extension BluetoothManager {
    func discoverServicesForConnectedPeripheral() {
        _connectedDevice?.discoverServices(nil)
    }
}
