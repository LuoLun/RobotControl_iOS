//
//  RobotManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import CoreBluetooth

class RobotManager: NSObject {
    
    typealias Robot = CBPeripheral
    
    let uuid = UUID().uuidString
    
    enum Mode: Int {
        case RunProgram = 0
        case RemoteControl = 1
    }
        
    var delegate: BluetoothManagerDelegate?
    let _bluetoothManager: BluetoothManager
    
    override init() {
        _bluetoothManager = BluetoothManager.sharedInstance
        super.init()
        
        _bluetoothManager.add(delegate: self)
    }
    
    func getRobot() {
        _bluetoothManager.showAllDevices()
    }
    
    func filterDevices() -> Set<Robot> {
        // TODO: (#5)过滤不是机器人的设备
        return _bluetoothManager._devices
    }
    
    func connectTo(robot: Robot) {
        _bluetoothManager.connectionToDevice(device: robot)
    }
    
    func send(commandString: String) -> Bool {
        return _bluetoothManager.send(data: "{\"code\": \"\(commandString)\"}".data(using: String.Encoding.ascii)!)
    }
    
    func send(state: String) -> Bool {
        return _bluetoothManager.send(data: "{\"state\": \(state)}".data(using: String.Encoding.ascii)!)
    }
    
    func setMode(mode: Mode) -> Bool {
        return _bluetoothManager.send(data: "{\"mode\": \(mode.rawValue)}".data(using: String.Encoding.utf8)!)
    }
    
    func forceStopRunning() -> Bool {
        return _bluetoothManager.send(data: "{\"forceStop\": 1}".data(using: String.Encoding.utf8)!)
    }
    
    func hasConnectedRobot() -> Bool {
        return _bluetoothManager._connectedDevice != nil
    }
}

extension RobotManager: BluetoothManagerDelegate {
    func bluetoothManagerDidUpdateState(_ state: CBManagerState) {
        delegate?.bluetoothManagerDidUpdateState(state)
    }
    
    func bluetoothManagerdidUpdateDeviceList(_ deviceList: Set<CBPeripheral>) {
        delegate?.bluetoothManagerdidUpdateDeviceList(deviceList)
    }
    
    func bluetoothManagerFinishConnection(to device: CBPeripheral, success: Bool, error: Error?) {
        delegate?.bluetoothManagerFinishConnection(to: device, success: success, error: error)
    }
    
    func bluetoothManagerDidDisconnection(to device: CBPeripheral, error: Error?) {
        delegate?.bluetoothManagerDidDisconnection(to: device, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.peripheral(peripheral, didWriteValueFor: characteristic, error: error)
    }
}
