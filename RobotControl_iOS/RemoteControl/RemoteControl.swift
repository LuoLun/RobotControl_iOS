//
//  RemoteControl.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import CoreBluetooth

class RemoteControl: NSObject {

    var delegate: BluetoothManagerDelegate?
    
    let uuid = UUID().uuidString
    
    let _robotManager = RobotManager()
    
    override init() {
        super.init()
        _robotManager.delegate = self
    }
    
    func send(state: String) -> Bool {
        return _robotManager.send(state: state)
    }
    
}

extension RemoteControl: BluetoothManagerDelegate {
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
