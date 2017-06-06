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
    
    override init(block: Block, layoutConfig: LayoutConfig) {
        super.init(block: block, layoutConfig: layoutConfig)
        self.layer.addSublayer(_backgroundLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func blockBackgroundBezierPath() -> UIBezierPath {
        let path = BlockBezierPath()
        
        let notchWidth = layoutConfig.notchWidth
        let notchHeight = layoutConfig.notchHeight
        
        path.moveTo(x: 0, y: 0)
        
        if self.block.previousConnection != nil {
            PathHelper.addNotch(toPath: path, drawLeftToRight: true, notchWidth: notchWidth, notchHeight: notchHeight)
        }
        path.addLineTo(x: self.frame.width, y: 0, relative: false)
        
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
                path.addLineTo(x: blockInputView.statementIndent + notchWidth, y: path.currentY(), relative: false)
                PathHelper.addNotch(toPath: path, drawLeftToRight: false, notchWidth: notchWidth, notchHeight: notchHeight)
                path.addLineTo(x: path.currentY(), y: blockInputView.frame.height, relative: false)
                PathHelper.addNotch(toPath: path, drawLeftToRight: true, notchWidth: notchWidth, notchHeight: notchHeight)
                path.addLineTo(x: lastInputWidth ?? self.frame.width, y: path.currentY(), relative: false)
            }
        }
        
        path.addLineTo(x: 0, y: 4, relative: true)
        
        if self.block.nextConnection != nil {
            path.addLineTo(x: notchWidth, y: path.currentY(), relative: false)
            PathHelper.addNotch(toPath: path, drawLeftToRight: false, notchWidth: notchWidth, notchHeight: notchHeight)
        }
        else {
            path.addLineTo(x: 0, y: path.currentY(), relative: false)
        }
        path.addLineTo(x: 0, y: 0, relative: false)
        
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
}
