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
    
    enum Mode: Int {
        case RunProgram = 0
        case RemoteControl = 1
    }
    
    public static let shared = RobotManager()
    
    var delegate: BluetoothManagerDelegate?
    let _bluetoothManager: BluetoothManager
    
    private override init() {
        _bluetoothManager = BluetoothManager.sharedInstance
//        _bluetoothManager.add(delegate: self)
        super.init()
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
        return _bluetoothManager.send(data: commandString.data(using: String.Encoding.ascii)!)
    }
    
    func setMode(mode: Mode) {
//        _bluetoothManager.send(data: "setMode(\(mode.rawValue));")
    }
    
    func forceStopRunning() {
        
    }
    
    func hasConnectedRobot() -> Bool {
        return _bluetoothManager._connectedDevice != nil
    }
}

//extension RobotManager: BluetoothManagerDelegate {
//    
//}
