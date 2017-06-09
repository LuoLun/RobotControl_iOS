//
//  RoutePlanView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/9.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol RoutePlanViewDelegate: class {
    func finishDraw(with points: [CGPoint])
}

class RoutePlanView: UIView {

    var _points = [CGPoint]()
    var _time = [Any]()
    
    var delegate: RoutePlanViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(panGesture)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            _points.removeAll()
            _time.removeAll()
        case .changed:
            let time = NSDate.timeIntervalSinceReferenceDate * 1000
            let point = panGesture.location(in: self)
            _points.append(point)
            _time.append(time)
            setNeedsDisplay()
        case .ended:
            delegate?.finishDraw(with: _points)
        default:
            break
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        guard let startPoint = _points.first else {
            return
        }
        
        context.setStrokeColor(UIColor.black.cgColor)
        
        context.move(to: startPoint)
        for point in _points {
            context.addLine(to: point)
        }
        context.strokePath()
    }
}
