//
//  InputBuilder.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class InputBuilder: NSObject {
    enum InputType {
        case FieldInput
        case BlockInput
    }
    
    var fields: [Field]?
    
    let inputType: InputType
    let inputName: String
    
    init(name: String, inputType: InputType) {
        self.inputType = inputType
        self.inputName = name
        super.init()
    }
    
    func buildInput() -> Input {
        
        let input: Input
        switch inputType {
        case .FieldInput:
            input = FieldInput(name: inputName)
        case .BlockInput:
            let blockInput = BlockInput(name: inputName)
            blockInput.connection.sourceInput = blockInput
            input = blockInput
        }
        
        for field in fields! {
            input.appendField(field.copiedField())
        }
        
        return input
    }
}
