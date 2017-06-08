//
//  RemoteControlView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol RemoteControlViewDelegate {
    // 角度向右为正
    // 两个参数的绝对值范围都是0~1
    func move(angleRatio: CGFloat, speedRatio: CGFloat)
}

class RemoteControlView: UIView {

    var delegate: RemoteControlViewDelegate?
    
    let _leftJoystick = CircleView()
    let _rightJoystick = CircleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
        

        let leftGesture = UIPanGestureRecognizer(target: self, action: #selector(panJoystick(_:)))
        _leftJoystick.addGestureRecognizer(leftGesture)
        
        let rightGesture = UIPanGestureRecognizer(target: self, action: #selector(panJoystick(_:)))
        _rightJoystick.addGestureRecognizer(rightGesture)
        
        
        
        self.addSubview(_leftJoystick)
        self.addSubview(_rightJoystick)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.frame.size
        let height = size.height
        let width = size.width
        
        var padWidth = size.width
        var padHeight = padWidth / 2
        
        if padHeight > size.height {
            padHeight = size.height
            padWidth = padHeight * 2
        }
        
        let originX = (width - padWidth) / 2, originY = (height - padHeight) / 2
        
        _leftJoystickRect = CGRect(x: originX, y: originY + padHeight / 8 * 3, width: padWidth / 2, height: padHeight / 4)
        _rightJoystickRect = CGRect(x: originX + padWidth / 2 + padWidth / 2 / 8 * 3, y: 0, width: padWidth / 2 / 4, height: padHeight)
        
        let widthAndHeight = min(padWidth, padHeight) / 4
        _leftJoystick.frame.size = CGSize(width: widthAndHeight, height: widthAndHeight)
        _rightJoystick.frame.size = CGSize(width: widthAndHeight, height: widthAndHeight)
        
        _leftJoystick.center = CGPoint(x: _leftJoystickRect.midX, y: _leftJoystickRect.midY)
        _rightJoystick.center = CGPoint(x: _rightJoystickRect.midX, y: _rightJoystickRect.midY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func panJoystick(_ panGesture: UIPanGestureRecognizer) {
        let joystick = panGesture.view!
        let rect = (joystick == _leftJoystick) ? _leftJoystickRect : _rightJoystickRect
        
        switch panGesture.state {
        case .changed:
            let panPoint = panGesture.location(in: self)
            var x = joystick.center.x
            var y = joystick.center.y
            if panPoint.x > rect.origin.x && panPoint.x < rect.origin.x + rect.width {
                x = panPoint.x
            }
            if panPoint.y > rect.origin.y && panPoint.y < rect.origin.y + rect.height {
                y = panPoint.y
            }
            joystick.center = CGPoint(x: x, y: y)
        case .ended:
            joystick.center = CGPoint(x: rect.midX, y: rect.midY)
        default:
            break
        }
        
        let angleRetio = (_leftJoystick.frame.midX - _leftJoystickRect.midX) / (_leftJoystickRect.width / 2)
        let speedRatio = -(_rightJoystick.frame.midY - _rightJoystickRect.midY) / (_rightJoystickRect.height / 2)
        
        delegate?.move(angleRatio: angleRetio, speedRatio: speedRatio)
    }
    
    override func draw(_ rect: CGRect) {
        let size = self.frame.size
        let height = size.height
        let width = size.width
        
        var padWidth = size.width
        var padHeight = padWidth / 2
        
        if padHeight > size.height {
            padHeight = size.height
            padWidth = padHeight * 2
        }
        
        let originX = (width - padWidth) / 2, originY = (height - padHeight) / 2
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        
        context.beginPath()
        _leftJoystickRect = CGRect(x: originX, y: originY + padHeight / 8 * 3, width: padWidth / 2, height: padHeight / 4)
        context.addRect(_leftJoystickRect)
        context.fillPath()
        
        context.beginPath()
        _rightJoystickRect = CGRect(x: originX + padWidth / 2 + padWidth / 2 / 8 * 3, y: 0, width: padWidth / 2 / 4, height: padHeight)
        context.addRect(_rightJoystickRect)
        context.fillPath()
        
        super.draw(rect)
    }
    
    
    var _leftJoystickRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var _rightJoystickRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    class CircleView: UIView {
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            // 假设本view一定是正方形
            let height = self.frame.size.height
            let width = self.frame.size.width
            
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.red.cgColor)
            
            context.addArc(center: CGPoint(x: width / 2, y: height / 2), radius: width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            context.fillPath()
        }
        
    }
}
