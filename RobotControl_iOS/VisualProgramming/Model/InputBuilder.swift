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
    
    init(inputType: InputType) {
        self.inputType = inputType
        super.init()
    }
    
    func buildInput() -> Input {
        
        let input: Input
        switch inputType {
        case .FieldInput:
            input = FieldInput()
        case .BlockInput:
            input = BlockInput()
        }
        
        for field in fields! {
            input.appendField(field.copiedField())
        }
        
        return input
    }
}
