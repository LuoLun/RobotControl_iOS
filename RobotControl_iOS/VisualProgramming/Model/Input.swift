//
//  Input.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Input: NSObject {
    var fields = [Field]()
}

class FieldInput: Input {
    func appendField(_ field: Field) {
        fields.append(field)
    }
}

class BlockInput: Input {
    let connection = Connection(category: .child)
    
    var blocks = [Block]()
    func appendBlock(_ block: Block) {
        blocks.append(block)
    }
}
