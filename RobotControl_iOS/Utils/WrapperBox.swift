//
//  WrapperBox.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class WrapperBox<T>: NSObject {
    private let _unbox: T
    
    init(unbox: T) {
        _unbox = unbox
    }
    
    var unbox: T {
        return _unbox
    }
}
