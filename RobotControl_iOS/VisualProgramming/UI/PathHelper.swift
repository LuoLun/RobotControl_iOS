//
//  PathHelper.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class PathHelper: NSObject {
    class func addNotch(toPath path: BlockBezierPath, drawLeftToRight: Bool, notchWidth: CGFloat, notchHeight: CGFloat) {
        if drawLeftToRight {
            path.addLineTo(x: notchWidth - 15, y: 0, relative: true)
            path.addLineTo(x: 6, y: notchHeight, relative: true)
            path.addLineTo(x: 3, y: 0, relative: true)
            path.addLineTo(x: 6, y: -notchHeight, relative: true)
        }
        else {
            path.addLineTo(x: -6, y: notchHeight, relative: true)
            path.addLineTo(x: -3, y: 0, relative: true)
            path.addLineTo(x: -6, y: -notchHeight, relative: true)
            path.addLineTo(x: -(notchWidth - 15), y: 0, relative: true)
        }
    }
}
