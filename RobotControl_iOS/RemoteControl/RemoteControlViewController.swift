//
//  RemoveControlViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class RemoteControlViewController: UIViewController, RemoteControlViewDelegate {

    var _remoteControl: RemoteControl?
    
    var _sendStatusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        
        _remoteControl = RemoteControl()
        
        let remoteControlView = RemoteControlView()
        remoteControlView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(remoteControlView)
        remoteControlView.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40))
        
        remoteControlView.delegate = self
        
        _sendStatusLabel = UILabel()
        _sendStatusLabel!.numberOfLines = 0
        
        _sendStatusLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_sendStatusLabel!)
        _sendStatusLabel!.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets.zero, options: [.Top, .Right])
    }

    func move(angleRatio: CGFloat, speedRatio: CGFloat) {
        let stateString = "{\"angleRatio\": \(angleRatio), \"speedRatio\": \(speedRatio)}"
        let canSend = _remoteControl!.send(state: stateString)
        _sendStatusLabel!.text = "发送状态:\(canSend == true ? "已发送": "未发送")\n"
                                .appending("\(stateString)")
    }
}
