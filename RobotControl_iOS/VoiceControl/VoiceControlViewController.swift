//
//  VoiceControlViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/9.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit


class VoiceControlViewController: UIViewController {

    var _statusLabel: UILabel?
    var _resultLabel: UILabel?
    var _button: UIButton?
    
    var _active = false
    
    var _voiceControl: VoiceControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        
        do {
            _voiceControl = try VoiceControl(delegate: self)
        } catch let error {
            let alert = UIAlertController(title: "初始化错误", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_: UIAlertAction) in
                self.navigationController!.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }

        
        _statusLabel = UILabel()
        _statusLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_statusLabel!)
        _statusLabel!.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), options: [.Top, .Right])
        
        _statusLabel!.numberOfLines = 0
        _statusLabel!.textColor = UIColor.black
        
        _resultLabel = UILabel()
        _resultLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_resultLabel!)
        _resultLabel!.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), options: [.Right])
        NSLayoutConstraint(item: _resultLabel!, attribute: .top, relatedBy: .equal, toItem: _statusLabel, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        _resultLabel!.numberOfLines = 0
        _resultLabel!.textColor = UIColor.black
        
        _button = UIButton()
        _button!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_button!)
        NSLayoutConstraint(item: _button!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: _button!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        _button?.setTitle("开始语音控制", for: .normal)
        _button?.setTitleColor(UIColor.black, for: .normal)
        _button?.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        

    }
    
    func toggleButton() {
        
        if !_active && beginListenning() {
            _active = true
        }
        else if _active && stopListening() {
            _active = false
        }
        
        if _active {
            _button?.setTitle("结束语音控制", for: .normal)
        } else {
            _button?.setTitle("开始语音控制", for: .normal)
        }
    }
    
    func beginListenning() -> Bool {
        return _voiceControl!.beginSpeak()
    }
    
    func stopListening() -> Bool {
        return _voiceControl!.stopSpeak()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    
    func postError(error: Error, title: String, quit: Bool) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "退出", style: .default, handler: { (_: UIAlertAction) in
            if quit {
                self.navigationController!.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension VoiceControlViewController: VoiceControlDelegate {
    func finishRecognition(bestResult: String, allResult: [String: Float]) {
        _resultLabel!.text = "命令:\(bestResult) 代码:\(String(describing: _voiceControl?.toCommandString(bestResult)))"
    }
    
    
    func loadGrammarError(_ error: Error) {
        postError(error: error, title: "读取语法文件出错", quit: true)
    }
    
    func error(_ error: Error) {
        _statusLabel!.text = "未知错误：\(error.localizedDescription)"
    }
    
    
    func voiceControlDidBeginListening() {
        _statusLabel!.text = "正在聆听"
    }
    
    func voiceControlDidEndListening() {
        _statusLabel!.text = "已结束说话"
    }
    
    func voiceControlDidCancel() {
        _statusLabel!.text = "已取消"
    }
    
    
    func robotNotConnected() {
        _statusLabel!.text = "未连接到机器人"
    }
    
    
    func hasSentCommand() {
        _statusLabel!.text = "已发送命令"
    }
    
    func sendConnamdFailed() {
        _statusLabel!.text = "发送命令失败"
    }
    
    func grammarError(error: Error) {
        _statusLabel!.text = "语法错误：\(error.localizedDescription)"
    }
}
