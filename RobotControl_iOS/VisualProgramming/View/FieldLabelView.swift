//
//  FieldLabelView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldLabelView: FieldView {

    let label: UILabel
    
    let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    var fieldLabel: FieldLabel {
        return field as! FieldLabel
    }
    
    override init() {
        label = UILabel()
        super.init()
        
        self.autolayout_addSubview(label)
        label.makeConstraintsEqualTo(self, edgeInsets: edgeInsets)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSetField(_ field: Field?) {
        label.text = fieldLabel.text
    }
}
