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
    var workspaceView: WorkspaceView?
    
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
            
            inputView.sourceBlockView = blockView
        }
        
        blockView.block.directConnections.forEach{ $0.delegate = blockView }
        blockView.block.directConnections.forEach{ $0.positionListener = blockView }

        
        blockView.workspaceView = workspaceView
        return blockView
    }
    
    func buildInputView(_ input: Input) -> InputView {
        
        var view: InputView?
        if input is FieldInput {
            view = buildFieldInputView(input as! FieldInput)
        }
        else if input is BlockInput {
            view = buildBlockInputView(input as! BlockInput)
        }
        else {
            fatalError()
        }
        
        return view!
    }
    
    func buildFieldInputView(_ input: FieldInput) -> FieldInputView {
        let fieldInputView = FieldInputView(fieldInput: input, layoutConfig: layoutConfig)
        
        for field in input.fields {
            let fieldView = buildFieldView(field)
            fieldInputView.addSubview(fieldView)
            
            fieldView.sourceInputView = fieldInputView
        }
        
        return fieldInputView
    }
    
    func buildBlockInputView(_ input: BlockInput) -> BlockInputView {
        let blockInputView = BlockInputView(input: input, layoutConfig: layoutConfig)
        
        for field in input.fields {
            let fieldView = buildFieldView(field)
            blockInputView.addSubview(fieldView)
            
            fieldView.sourceInputView = blockInputView
        }
        
//        for block in input.blocks {
//            let blockView = buildBlockView(block)
//            blockInputView.addSubview(blockView)
//        }
        
        return blockInputView
    }
    
    func buildFieldView(_ field: Field) -> FieldView {
        if field is FieldLabel {
            let fieldLabelView = FieldLabelView(layoutConfig: layoutConfig)
            fieldLabelView.field = field
            return fieldLabelView
        }
        if field is FieldVariable {
            let fieldVariableView = FieldVariableView(layoutConfig: layoutConfig)
            fieldVariableView.field = field
            return fieldVariableView
        }
        return FieldView(layoutConfig: layoutConfig)
    }
}
