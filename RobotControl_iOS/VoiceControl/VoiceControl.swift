//
//  VoiceControl.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/9.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

protocol VoiceControlDelegate {
    func finishRecognition(bestResult: String, allResult: [String: Float])
    
    func loadGrammarError(_ error: Error)
    func error(_ error: Error)
    
    func voiceControlDidBeginListening()
    func voiceControlDidEndListening()
    func voiceControlDidCancel()
    
    func robotNotConnected()
    
    func hasSentCommand()
    func sendConnamdFailed()
    func grammarError(error: Error)
}

class VoiceControl: NSObject {
    
    var _voiceRecognizerAdapter: VoiceRecognizerAdapter?
    var _robotManager: RobotManager?
    let delegate: VoiceControlDelegate
    
    // TODO: (#10) 可以进一步优化，在初始化的时候把json转换成编译类
    var _compilerJson: [String: Any]?
    
    init(delegate: VoiceControlDelegate) throws {
        self.delegate = delegate
        super.init()
        
        _voiceRecognizerAdapter = try VoiceRecognizerAdapter(delegate: self)
        
        _robotManager = RobotManager()
        _robotManager!.delegate = self
        
//        try loadCompileDef()
    }
    
    func beginSpeak() -> Bool {
        return canRecord() && _voiceRecognizerAdapter!.recognizeSpeech()
    }
    
    func stopSpeak() -> Bool {
        return _voiceRecognizerAdapter!.stopSpeech()
    }
    
    private func loadCompileDef() throws {
        let path = Bundle.main.path(forResource: "VoiceCommandCompileDef", ofType: "json")!
        let defString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        guard let compilerJson = try JSONSerialization.jsonObject(with: defString.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
            throw VoiceControlError("Error when reading voice command compile definition file.", code: -1)
        }
        _compilerJson = compilerJson
    }
    
    private func canRecord() -> Bool{
        var granted = true
        if UIDevice.current.systemVersion.compare("7.0") == .orderedAscending {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
                audioSession.requestRecordPermission({ (userGranted: Bool) in
                    granted = userGranted
                })
            }
        }
        return granted
    }
}

extension VoiceControl: VoiceRecognizerAdapterDelegate {
    
    func initError(_ error: Error) {
        delegate.error(error)
    }
    
    func error(_ error: Error) {
        delegate.error(error)
    }
    
    func onResult(best: String, all: [String: Float]) {
        // 用文字告知用户结果
        delegate.finishRecognition(bestResult: best, allResult: all)
        
        // TODO:(#9) 当置信度最高的几个词置信度一样的时候，询问用户执行哪操作
        
        if _robotManager!.state == .Connected {
            // 停止需要特殊处理
            if best == "机器人停止" {
                _robotManager!.forceStopRunning()
            }
            
            guard let commandString = toCommandString(best) else {
                delegate.grammarError(error: VoiceControlError("Wrong grammar of command: \n \(best)", code: -1))
                return
            }
            
            if false == _robotManager?.send(commandString: commandString) {
                delegate.sendConnamdFailed()
            } else {
                delegate.hasSentCommand()
            }
        } else {
            delegate.robotNotConnected()
        }
    }
    
    func onBeginSpeech() {
        delegate.voiceControlDidBeginListening()
    }
    
    func onFinishSpeech() {
        delegate.voiceControlDidEndListening()
    }
    
    func onCancel() {
        delegate.voiceControlDidCancel()
    }
    
    // MARK: -
    
    func toCommandString(_ text: String) -> String? {
        if text.hasPrefix("前进") {
            let numberText = text.replacingOccurrences(of: "前进", with: "").replacingOccurrences(of: "米", with: "")
            guard let number = textToNumber(numberText) else {
                delegate.grammarError(error: VoiceControlError("Wrong grammar of command: \n \(text)", code: -1))
                return nil
            }
            return "move(\(number))"
        } else if text.hasPrefix("后退") {
            let numberText = text.replacingOccurrences(of: "后退", with: "").replacingOccurrences(of: "米", with: "")
            guard let number = textToNumber(numberText) else {
                delegate.grammarError(error: VoiceControlError("Wrong grammar of command: \n \(text)", code: -1))
                return nil
            }
            return "move(-\(number))"
        }
        return nil
    }
    
    func textToNumber(_ text: String) -> Int? {
        var result = 0
        
        var text = text
        text = text.replacingOccurrences(of: "一", with: "1")
        text = text.replacingOccurrences(of: "二", with: "2")
        text = text.replacingOccurrences(of: "三", with: "3")
        text = text.replacingOccurrences(of: "四", with: "4")
        text = text.replacingOccurrences(of: "五", with: "5")
        text = text.replacingOccurrences(of: "六", with: "6")
        text = text.replacingOccurrences(of: "七", with: "7")
        text = text.replacingOccurrences(of: "八", with: "8")
        text = text.replacingOccurrences(of: "九", with: "9")
        text = text.replacingOccurrences(of: "零", with: "")
        let nsText = text as NSString
        
        // 已经读取了一个digit
        var stateDigit = false
        var lastDigit = 0
        
        for i in 0..<text.characters.count {
            
            let c = nsText.character(at: i)
            
            // 是否最后一个字符
            let end = (i == (text.characters.count - 1))
            
            if c >= NSString(string: "0").character(at: 0) && c <= NSString(string: "9").character(at: 0) {
                let digit = Int(c - NSString(string: "0").character(at: 0))
                lastDigit = digit
                stateDigit = true
            } else if c == NSString(string: "十").character(at: 0) {
                lastDigit = stateDigit ? lastDigit : 1
                result += lastDigit * 10
                stateDigit = false
            } else if c == NSString(string: "百").character(at: 0) {
                lastDigit = stateDigit ? lastDigit : 1
                result += lastDigit * 100
                stateDigit = false
            } else if c == NSString(string: "千").character(at: 0) {
                lastDigit = stateDigit ? lastDigit : 1
                result += lastDigit * 1000
                stateDigit = false
            } else if c == NSString(string: "万").character(at: 0) {
                lastDigit = stateDigit ? lastDigit : 1
                result += lastDigit * 10000
                stateDigit = false
            }  else {
                return nil
            }
            
            if end {
                if stateDigit {
                    result += lastDigit
                }
            }
        }
        
        return result
    }
}

extension VoiceControl: RobotManagerDelegate {
    func bluetoothManagerDidUpdateState(_ state: CBManagerState) {
        
    }
    
    func robotManagerDidUpdateDeviceList(_ deviceList: Set<Robot>) {
        
    }
    
    func robotManagerDidConnect(to robot: Robot, success: Bool, error: Error?) {
        
    }
    
    func robotManagerDidDisconnection(to device: Robot, error: Error?) {
        
    }
    
    func robot(_ robot: Robot, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}

class VoiceControlError: RobotControlError {
    
}
