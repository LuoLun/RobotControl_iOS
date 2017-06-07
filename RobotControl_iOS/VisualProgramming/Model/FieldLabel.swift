//
//  FieldLabel.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldLabel: Field {
    let text: String
    
    init(name: String, text: String) {
        self.text = text
        super.init(name: name)
    }
    
    override func copiedField() -> Field {
        let fieldLabel = FieldLabel(name: name, text: text)
        return fieldLabel
    }
}
