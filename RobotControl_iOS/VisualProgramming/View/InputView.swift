//
//  InputView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class InputView: UIView {
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        return nil
//    }
}

class FieldInputView: InputView {
    override func layoutSubviews() {
        var size = CGSize.zero
        var x: CGFloat = 0
        for view in subviews {
            view.layoutSubviews()
            view.frame.origin.x = x
            view.frame.origin.y = 0
            x += view.frame.size.width
            size.width += view.frame.size.width
            size.height = max(view.frame.size.height, size.height)
        }
        self.frame.size = size
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        for view in subviews {
//            let convertedPoint = view.convert(point, from: self)
//            let view = view.hitTest(convertedPoint, with: event)
//            if view != nil {
//                return view
//            }
//        }
//        return nil
//    }
}

class BlockInputView: InputView {
    override func layoutSubviews() {
        var size = CGSize.zero
        var y: CGFloat = 0
        for view in subviews {
            view.layoutSubviews()
            view.frame.origin.y = y
            y += view.frame.size.height
            size.height += view.frame.size.height
            size.width = max(view.frame.size.width, size.width)
        }
        self.frame.size = size
    }

//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        for view in subviews {
//            let convertedPoint = view.convert(point, from: self)
//            let view = view.hitTest(convertedPoint, with: event)
//            if view != nil {
//                return view
//            }
//        }
//        return nil
//    }
}
