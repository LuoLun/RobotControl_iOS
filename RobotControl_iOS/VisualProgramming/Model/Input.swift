//
//  Input.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Input: NSObject {
    var _fields = [Field]()
    
    var fields: [Field] {
        return _fields
    }
    
    weak var sourceBlock: Block?
    
    func appendField(_ field: Field) {
        _fields.append(field)
        field.sourceInput = self
        field.sourceBlock = sourceBlock
    }
}

class FieldInput: Input {
}

class BlockInput: Input {
    let connection = Connection(category: .child)
    
    var blocks = [Block]()
    func appendBlock(_ block: Block) {
        blocks.append(block)
    }
}
