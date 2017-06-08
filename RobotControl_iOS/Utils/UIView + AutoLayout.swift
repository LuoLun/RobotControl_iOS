//
//  UIView + AutoLayout.swift
//  Utils
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

public extension UIView {

    public struct AlignOption: OptionSet {
        public static let Top = AlignOption(value: .top)
        public static let Left = AlignOption(value: .left)
        public static let Bottom = AlignOption(value: .bottom)
        public static let Right = AlignOption(value: .right)
        public static let All = AlignOption([.Top, .Left, .Bottom, .Right])

        public let rawValue : Int
        
        public init(rawValue: AlignOption.RawValue) {
            self.rawValue = rawValue
        }
        
        public init(value: Value) {
            self.init(rawValue: 1 << value.rawValue)
        }
        
        public enum Value: Int {
            case top
            case left
            case bottom
            case right
        }
        
        public func intersectsWith(_ other: AlignOption) -> Bool {
            return intersection(other).rawValue != 0
        }
    }
    
    public func autolayout_addSubview(_ view: UIView, translatesAutoResizingMaskIntoConstraints: Bool = false) {
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        self.addSubview(view)
    }
    
    public func autolayout_addSubviews(_ views: [UIView], translatesAutoResizingMaskIntoConstraints: Bool = false) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
            self.addSubview(view)
        }
    }
    
    public func makeConstraintsEqualTo(_ view: UIView) {
        makeConstraintsEqualTo(view, edgeInsets: UIEdgeInsets.zero, options: .All)
    }

    public func makeConstraintsEqualTo(_ view: UIView, edgeInsets: UIEdgeInsets) {
        makeConstraintsEqualTo(view, edgeInsets: edgeInsets, options: .All)
    }
    
    public func makeConstraintsEqualTo(_ view: UIView, edgeInsets: UIEdgeInsets, options: AlignOption) {
        if options.intersectsWith(.Top) {
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: edgeInsets.top).isActive = true

        }
        if options.intersectsWith(.Left) {
            NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: edgeInsets.left).isActive = true
            
        }
        if options.intersectsWith(.Right) {
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -edgeInsets.right).isActive = true
            
        }
        if options.intersectsWith(.Bottom) {
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -edgeInsets.bottom).isActive = true
            
        }
    }
}
