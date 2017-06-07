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
        
    var fieldLabel: FieldLabel {
        return field as! FieldLabel
    }
    
    override init(layoutConfig: LayoutConfig) {
        label = UILabel()
        super.init(layoutConfig: layoutConfig)
        
        label.font = layoutConfig.font
        self.addSubview(label)
//        label.makeConstraintsEqualTo(self, edgeInsets: edgeInsets)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSetField(_ field: Field?) {
        label.text = fieldLabel.text
    }
    
    override func layoutSubviews() {
        var size = CGSize.zero
        label.sizeToFit()
        size.width = contentEdgeInsets.left + label.frame.size.width + contentEdgeInsets.right
        size.height = contentEdgeInsets.top + label.frame.size.height + contentEdgeInsets.bottom
        label.frame.origin = CGPoint(x: contentEdgeInsets.left, y: contentEdgeInsets.left)
        self.frame.size = size
    }
}
