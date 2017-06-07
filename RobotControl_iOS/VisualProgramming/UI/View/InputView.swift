//
//  InputView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class InputView: LayoutView {
    let input: Input
    
    init(input: Input, layoutConfig: LayoutConfig) {
        self.input = input
        super.init(layoutConfig: layoutConfig)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 如果点击在InputView自身，则不把自身当作View处理。因为我们只想处理Field和Block的事件
        let hitTestView = super.hitTest(point, with: event)
        return (hitTestView == self) ? nil : hitTestView
    }
}

class FieldInputView: InputView {
    
    init(fieldInput: FieldInput, layoutConfig: LayoutConfig) {
        super.init(input: fieldInput, layoutConfig: layoutConfig)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fieldInput: FieldInput {
        return input as! FieldInput
    }
    
    override func layoutSubviews() {
        var size = CGSize.zero
        var x: CGFloat = 0
        for view in subviews {
            view.layoutSubviews()
            view.frame.origin.x = x
            view.frame.origin.y = 0
            x += view.frame.size.width
            size.width += view.frame.size.width
            size.height = max(view.frame.size.height, size.height)
        }
        self.frame.size = size
    }
    
}

class BlockInputView: InputView {
    
    var blockInput: BlockInput {
        return input as! BlockInput
    }
    
    override func layoutSubviews() {
        var size = CGSize.zero
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        statementIndent = layoutConfig.minStatementIndent
        
        if subviews.count == 0 {
            self.frame.size = layoutConfig.minBlockInputSize
            return
        }
        
        var i = 0
        while subviews[i] is FieldView {
            let fieldView = subviews[i] as! FieldView
            
            fieldView.layoutSubviews()
            fieldView.frame.origin.y = y
            fieldView.frame.origin.x = x
            x += fieldView.frame.width
            
            size.width += fieldView.frame.width
            
            i += 1
        }
        
        statementIndent = size.width
        
        var blocksTotalHeight: CGFloat = 0
        while subviews[i] is BlockView {
            let blockView = subviews[i] as! BlockView
            
            blockView.layoutSubviews()
            blockView.frame.origin.x = x
            blockView.frame.origin.y = y
            y += blockView.frame.height
            
            blocksTotalHeight += blockView.frame.height
            size.width = max(size.width, statementIndent + blockView.frame.width)
            
            i += 1
        }
        size.height = max(size.height, blocksTotalHeight)
        
        if i < subviews.count {
            fatalError()
        }
        
        self.frame.size = size
    }
    
    var statementIndent: CGFloat = 0
}
