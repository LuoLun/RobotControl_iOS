//
//  DefaultBlockView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class DefaultBlockView: BlockView {

    var previousConnectionRelativePosition: CGPoint?
    var nextConnectionRelativePosition: CGPoint?
    
    var _positionOfConnections = [Connection: CGPoint]()
    
    override init(block: Block, layoutConfig: LayoutConfig) {
        super.init(block: block, layoutConfig: layoutConfig)
        self.layer.addSublayer(_backgroundLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: - Shape(形状)
    
    var bezierPath: UIBezierPath?
    
    func blockBackgroundBezierPath() -> UIBezierPath {
        
        let path = BlockBezierPath()
        
        let notchWidth = layoutConfig.notchWidth
        let notchHeight = layoutConfig.notchHeight
        
        path.moveTo(x: 0, y: 0)
        
        if self.block.previousConnection != nil {
            _positionOfConnections[self.block.previousConnection!] = CGPoint(x: path.currentX() + notchWidth / 2, y: path.currentY() + notchHeight / 2)
            PathHelper.addNotch(toPath: path, drawLeftToRight: true, notchWidth: notchWidth, notchHeight: notchHeight)
        }
        
        var length:CGFloat = 0
        if subviews.count > 0 {
            subviews[0].layoutSubviews()
            length = subviews[0].frame.width
        } else {
            length = self.frame.width
        }
        path.addLineTo(x: length, y: 0, relative: false)
        
        // Head vertical space
        path.addLineTo(x: 0, y: 8, relative: true)
        
        var maxInputWidth: CGFloat = 0
        var lastInputWidth: CGFloat?
        
        // Field input and block input in block
        for i in 0..<subviews.count {
            let inputView = subviews[i]
            if inputView is FieldInputView {
                let fieldInputView = inputView as! FieldInputView
                fieldInputView.layoutSubviews()
                
                path.addLineTo(x: fieldInputView.frame.width, y: path.currentY(), relative: false)
                path.addLineTo(x: 0, y: fieldInputView.frame.height, relative: true)
                
                maxInputWidth = max(fieldInputView.frame.width, maxInputWidth)
                lastInputWidth = fieldInputView.frame.width
            }
            else if inputView is BlockInputView {
                let blockInputView = inputView as! BlockInputView
                blockInputView.layoutSubviews()
                
                path.addLineTo(x: blockInputView.statementIndent + notchWidth, y: path.currentY(), relative: false)
                _positionOfConnections[blockInputView.blockInput.connection] = CGPoint(x: path.currentX() - notchWidth / 2, y: path.currentY() + notchHeight / 2)
                PathHelper.addNotch(toPath: path, drawLeftToRight: false, notchWidth: notchWidth, notchHeight: notchHeight)
                path.addLineTo(x: 0, y: blockInputView.frame.height, relative: true)
                PathHelper.addNotch(toPath: path, drawLeftToRight: true, notchWidth: notchWidth, notchHeight: notchHeight)
                path.addLineTo(x: lastInputWidth ?? self.frame.width, y: path.currentY(), relative: false)
            }
        }
        
        if let last = subviews.last, last is BlockInputView {
            path.addLineTo(x: 0, y: 15, relative: true)
        } else {
            path.addLineTo(x: 0, y: 4, relative: true)
        }
        
        if self.block.nextConnection != nil {
            path.addLineTo(x: notchWidth, y: path.currentY(), relative: false)
            _positionOfConnections[self.block.nextConnection!] = CGPoint(x: path.currentX() - notchWidth / 2, y: path.currentY() + notchHeight / 2)
            PathHelper.addNotch(toPath: path, drawLeftToRight: false, notchWidth: notchWidth, notchHeight: notchHeight)
        }
        else {
            path.addLineTo(x: 0, y: path.currentY(), relative: false)
        }
        let height = path.currentY()
        path.addLineTo(x: 0, y: 0, relative: false)
        
        self.frame.size.height = height

        // 因为连接的位置已经更新，因此要告诉对等连接另一方这个连接位置已经更新，让对方根据连接的位置改变自身位置

        for connection in _positionOfConnections.keys {
            // 如果是前置连接，则不用告知，因为位置的决定顺序是“前置连接->后置连接“
            if connection.category == .previous {
                continue
            }
            
            connection.targetConnection?.positionListener?.updateWithoutOperation(connectionPosition: workspacePositionOf(connection), connection: connection.targetConnection!)
        }
        
        self.bezierPath = path
        return path
    }
    
    fileprivate let _backgroundLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let notchXOffset = layoutConfig.notchWidth / 2
        
        if self.block.previousConnection != nil {
            previousConnectionRelativePosition = CGPoint(x: notchXOffset, y: layoutConfig.notchHeight)
        }
        if self.block.nextConnection != nil {
            nextConnectionRelativePosition = CGPoint(x: notchXOffset, y: self.frame.height)
        }
        
        self._backgroundLayer.path = self.blockBackgroundBezierPath().cgPath
        self._backgroundLayer.fillRule = kCAFillRuleEvenOdd
        self._backgroundLayer.fillColor = UIColor.green.cgColor
        self._backgroundLayer.strokeColor = UIColor.black.cgColor
        self._backgroundLayer.frame = self.bounds
        self.setNeedsDisplay()
    }
    
    // MARK: - ConnectionDelegate
    
    override func workspacePositionOf(_ connection: Connection) -> CGPoint {
        if _positionOfConnections.count == 0 {
            self.layoutSubviews()
        }
        let blockPosition = _positionOfConnections[connection]!
        let workspacePosition = CGPoint(x: blockPosition.x + self.frame.origin.x, y: blockPosition.y + self.frame.origin.y)
        return workspacePosition
    }
    
    // MARK: - Hit test
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)
        
        if hitTestView == self {
            if let bezierPath = bezierPath, bezierPath.contains(point) {
                return self
            } else {
                return nil
            }
        }
        
        return hitTestView
    }
}

extension BlockView: ConnectionPositionListener {
    func updateWithoutOperation(connectionPosition: CGPoint, connection: Connection) {
        let posSelfConn = connection.workspacePosition()
        let delta = CGPoint(x: connectionPosition.x - posSelfConn.x, y: connectionPosition.y - posSelfConn.y)
        self.frame.origin.x += delta.x
        self.frame.origin.y += delta.y
    }
}
