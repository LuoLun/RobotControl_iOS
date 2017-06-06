//
//  FieldView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldView: LayoutView {

    var field: Field? {
        didSet {
            didSetField(field)
        }
    }

    override init(layoutConfig: LayoutConfig) {
        super.init(layoutConfig: layoutConfig)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSetField(_ field: Field?) {
        
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        return nil
//    }
}
