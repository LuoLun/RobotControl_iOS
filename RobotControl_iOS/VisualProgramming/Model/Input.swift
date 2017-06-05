//
//  Input.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Input: NSObject {
}

class FieldInput: Input {
    var fields = [Field]()
    
    func appendField(_ field: Field) {
        fields.append(field)
    }
}

class BlockInput: Input {
    let connection = Connection(category: .child)
}
