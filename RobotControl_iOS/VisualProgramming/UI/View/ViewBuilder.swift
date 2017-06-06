//
//  ViewBuilder.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class ViewBuilder: NSObject {
    
    var layoutConfig: LayoutConfig
    
    init(layoutConfig: LayoutConfig) {
        self.layoutConfig = layoutConfig
        super.init()
    }
    
    let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    func buildBlockView(_ block: Block) -> BlockView {
        let blockView = DefaultBlockView(block: block, layoutConfig: layoutConfig)
        
        for input in block.inputs {
            let inputView = buildInputView(input)
            blockView.addSubview(inputView)
        }
        
        blockView.block.directConnections.forEach{ $0.delegate = blockView }
        
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
        let fieldInputView = FieldInputView(fieldInput: input, layoutConfig: layoutConfig)
        
        for field in input.fields {
            let fieldView = buildFieldView(field)
            fieldInputView.addSubview(fieldView)
        }
        
        return fieldInputView
    }
    
    func buildBlockInputView(_ input: BlockInput) -> BlockInputView {
        let blockInputView = BlockInputView(input: input, layoutConfig: layoutConfig)
        
        for field in input.fields {
            let fieldView = buildFieldView(field)
            blockInputView.addSubview(fieldView)
        }
        
        for block in input.blocks {
            let blockView = buildBlockView(block)
            blockInputView.addSubview(blockView)
        }
        
        return blockInputView
    }
    
    func buildFieldView(_ field: Field) -> FieldView {
        if field is FieldLabel {
            let fieldLabelView = FieldLabelView(layoutConfig: layoutConfig)
            fieldLabelView.field = field
            return fieldLabelView
        }
        return FieldView(layoutConfig: layoutConfig)
    }
}
