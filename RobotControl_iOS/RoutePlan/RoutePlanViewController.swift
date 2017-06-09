//
//  RoutePlanViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/9.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class RoutePlanViewController: UIViewController, RoutePlanViewDelegate {

    var _textField: UITextField?
    var _label: UILabel?
    var _confirmRatioButton: UIButton?
    
    var _result: String = ""
    
    var _ratio: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        
        self.view.backgroundColor = UIColor.gray
        
        let routePlanView = RoutePlanView()
        routePlanView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(routePlanView)
        routePlanView.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40))
        
        routePlanView.delegate = self
        
        _label = UILabel()
        _label?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_label!)
        _label?.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets.zero, options: [.Top, .Right])
        
        _label!.text = "在这里输入比例尺，单位是厘米／像素"
        _label!.textColor = UIColor.black
        
        _textField = UITextField()
        _textField!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_textField!)
        NSLayoutConstraint(item: _textField!, attribute: .top, relatedBy: .equal, toItem: _label, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: _textField!, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 60).isActive = true
        _textField!.backgroundColor = UIColor.yellow
        
        _textField!.textColor = UIColor.black
        
        _confirmRatioButton = UIButton()
        _confirmRatioButton!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_confirmRatioButton!)
        _confirmRatioButton!.makeConstraintsEqualTo(self.view, edgeInsets: .zero, options: .Right)
        NSLayoutConstraint(item: _confirmRatioButton!, attribute: .top, relatedBy: .equal, toItem: _textField, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: _confirmRatioButton!, attribute: .left, relatedBy: .equal, toItem: _textField, attribute: .right, multiplier: 1, constant: 0).isActive = true

        
        _confirmRatioButton!.setTitle("确定", for: .normal)
        _confirmRatioButton!.setTitleColor(UIColor.black, for: .normal)
        _confirmRatioButton!.addTarget(self, action: #selector(confirmRatio), for: .touchUpInside)
        
        let showResultButton = UIButton()
        showResultButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(showResultButton)
        showResultButton.makeConstraintsEqualTo(self.view, edgeInsets: .zero, options: .Right)
        NSLayoutConstraint(item: showResultButton, attribute: .top, relatedBy: .equal, toItem: _confirmRatioButton, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        showResultButton.setTitle("显示指令", for: .normal)
        showResultButton.addTarget(self, action: #selector(showResult), for: .touchUpInside)
        showResultButton.setTitleColor(UIColor.black, for: .normal)
    }

    func confirmRatio() {
        _textField!.endEditing(true)
        
        let ratio = NSString(string: _textField!.text!).floatValue
        
        if ratio < 0.00001 {
            let alertController = UIAlertController.messageAlert(title: "输入错误", message: "只能输入数字和小数点，并且数值不能太小，请重新输入")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        _ratio = CGFloat(ratio)
    }
    
    func finishDraw(with points: [CGPoint]) {
        _result.removeAll()
        
        if points.count < 7 {
            return
        }
        
        for i in 0..<points.count - 6 {
            let p1 = points[i]
            let p2 = points[i + 3]
            let p3 = points[i + 6]
            
            let d1 = pow(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2), 0.5)
            let d2 = pow(pow(p3.x - p2.x, 2) + pow(p3.y - p2.y, 2), 0.5)
            
            if d1 == 0 || d2 == 0 {
                continue
            }
            
            let r1 = CGVector(dx: p2.x - p1.x, dy: p2.y - p1.y)
            let r2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)
            
            let cos_theta = (r1.dx * r2.dx + r1.dy * r2.dy) / (d1 * d2)
            var theta = acos(cos_theta) / (CGFloat.pi * 2) * 360
            
            let crossProduct = r1.dx * r2.dy - r2.dx * r1.dy
            if crossProduct < 0 {
                theta *= -1
            }
            
            _result.append("move(\(d1 * _ratio))\n")
            _result.append("turn(\(theta))\n")
            _result.append("move(\(d2 * _ratio))\n")
        }
    }
    
    func showResult() {
        let alert = UIAlertController.messageAlert(title: "结果", message: _result)
        self.present(alert, animated: true, completion: nil)
    }

}
