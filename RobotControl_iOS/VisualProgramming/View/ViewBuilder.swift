//
//  ViewBuilder.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class ViewBuilder: NSObject {
    
    let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    func buildBlockView(_ block: Block) -> BlockView {
        let blockView = BlockView(block: block)
        
        var inputViews = [InputView]()
        
        for i in 0..<block.inputs.count {
            let input = block.inputs[i]
            
            let inputView = buildInputView(input)
            blockView.autolayout_addSubview(inputView)
            
            NSLayoutConstraint(item: inputView, attribute: .left, relatedBy: .equal, toItem: blockView, attribute: .left, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: inputView, attribute: .right, relatedBy: .equal, toItem: blockView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            
            if i == 0 {
                NSLayoutConstraint(item: inputView, attribute: .top, relatedBy: .equal, toItem: blockView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            }
            else if i == block.inputs.count - 1 {
                NSLayoutConstraint(item: inputView, attribute: .bottom, relatedBy: .equal, toItem: blockView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            }
                
            if i > 0 {
                NSLayoutConstraint(item: inputView, attribute: .top, relatedBy: .equal, toItem: inputViews[i - 1], attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            }
            
            inputViews.append(inputView)
        }
        
        return blockView
    }
    
    func buildInputView(_ input: Input) -> InputView {
        
        if input is FieldInput {
            return buildFieldInputView(input as! FieldInput)
        }
        else if input is BlockInput {
            return buildBlockInputView(input as! BlockInput)
        }
        else {
            fatalError()
        }
        
    }
    
    func buildFieldInputView(_ input: FieldInput) -> FieldInputView {
        let fieldInputView = FieldInputView()
        
        var fieldViews = [FieldView]()
        for i in 0..<input.fields.count {
            let field = input.fields[i]
            
            let fieldView = buildFieldView(field)
            fieldInputView.autolayout_addSubview(fieldView)
            
            NSLayoutConstraint(item: fieldView, attribute: .top, relatedBy: .equal, toItem: fieldInputView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: fieldView, attribute: .bottom, relatedBy: .equal, toItem: fieldInputView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            
            if i == 0 {
                NSLayoutConstraint(item: fieldView, attribute: .left, relatedBy: .equal, toItem: fieldInputView, attribute: .left, multiplier: 1, constant: 0).isActive = true
            }
            else if i == input.fields.count - 1 {
                NSLayoutConstraint(item: fieldView, attribute: .right, relatedBy: .equal, toItem: fieldInputView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
            
            if i > 0 {
                NSLayoutConstraint(item: fieldView, attribute: .left, relatedBy: .equal, toItem: fieldViews[i - 1], attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
            
            fieldViews.append(fieldView)
        }
        
        return fieldInputView
    }
    
    func buildBlockInputView(_ input: BlockInput) -> BlockInputView {
        return BlockInputView()
    }
    
    func buildFieldView(_ field: Field) -> FieldView {
        if field is FieldLabel {
            let fieldLabelView = FieldLabelView()
            fieldLabelView.translatesAutoresizingMaskIntoConstraints = false
            fieldLabelView.field = field
            return fieldLabelView
        }
        return FieldView()
    }
}
