//
//  BlockBezierPath.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockBezierPath: UIBezierPath {
    private var _x: CGFloat = 0
    private var _y: CGFloat = 0
    
    func currentX() -> CGFloat {
        return _x
    }
    
    func currentY() -> CGFloat {
        return _y
    }
    
    func moveTo(x: CGFloat, y: CGFloat) {
        super.move(to: CGPoint(x: x, y: y))
        _x = x
        _y = y
    }
    
    func addLineTo(x: CGFloat, y: CGFloat, relative: Bool) {
        if relative {
            _x += x
            _y += y
            addLine(to: CGPoint(x: _x, y: _y))
        }
        else {
            _x = x
            _y = y
            addLine(to: CGPoint(x: x, y: y))
        }
    }
}
