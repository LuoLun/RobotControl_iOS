//
//  RobotManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import CoreBluetooth

typealias Robot = CBPeripheral

protocol RobotManagerDelegate: class {
    func bluetoothManagerDidUpdateState(_ state: CBManagerState)
    
    func robotManagerDidUpdateDeviceList(_ deviceList: Set<Robot>)
    
    func robotManagerDidConnect(to robot: Robot, success: Bool, error: Error?)
    
    func robotManagerDidDisconnection(to device: CBPeripheral, error: Error?)
    
    func robot(_ robot: Robot, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
}

class RobotManager: NSObject {
    
    let uuid = UUID().uuidString
    
    enum Mode: Int {
        case RunProgram = 0
        case RemoteControl = 1
    }
    
    enum State {
        case Connected
        case Disconnected
    }
    
    var delegate: RobotManagerDelegate?
    let _bluetoothManager: BluetoothManager
    
    var _state: State = .Disconnected
    var state: State {
        return _state
    }
    
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
        var robots = Set<Robot>()
        for device in _bluetoothManager._devices {
            if isRobot(device: device) {
                robots.insert(device)
            }
        }
        return robots
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
    
    func isRobot(device: CBPeripheral) -> Bool {
        return true
    }
}

extension RobotManager: BluetoothManagerDelegate {
    func bluetoothManagerDidUpdateState(_ state: CBManagerState) {
        delegate?.bluetoothManagerDidUpdateState(state)
    }
    
    func bluetoothManagerdidUpdateDeviceList(_ deviceList: Set<CBPeripheral>) {
        let robotList = filterDevices()
        delegate?.robotManagerDidUpdateDeviceList(robotList)
    }
    
    func bluetoothManagerFinishConnection(to device: CBPeripheral, success: Bool, error: Error?) {
        if isRobot(device: device) {
            _state = .Connected
            delegate?.robotManagerDidConnect(to: device, success: success, error: error)
        }
    }
    
    func bluetoothManagerDidDisconnection(to device: CBPeripheral, error: Error?) {
        if isRobot(device: device) {
            _state = .Disconnected
            delegate?.robotManagerDidDisconnection(to: device, error: error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if isRobot(device: peripheral) {
            delegate?.robot(peripheral, didWriteValueFor: characteristic, error: error)
        }
    }
}
