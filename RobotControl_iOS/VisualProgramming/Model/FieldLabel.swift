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
    
    init(text: String) {
        self.text = text
    }
    
    override func copiedField() -> Field {
        let fieldLabel = FieldLabel(text: text)
        return fieldLabel
    }
}
