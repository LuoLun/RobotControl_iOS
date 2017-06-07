//
//  FieldView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldView: LayoutView {

    static let ContentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    var contentEdgeInsets: UIEdgeInsets {
        return FieldView.ContentEdgeInsets
    }
    
    var field: Field? {
        didSet {
            didSetField(field)
        }
    }
    
    var sourceInputView: InputView?
    
    var workspaceView: WorkspaceView? {
        return sourceInputView?.sourceBlockView?.workspaceView
    }

    override init(layoutConfig: LayoutConfig) {
        super.init(layoutConfig: layoutConfig)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subclass
    
    func didSetField(_ field: Field?) {
        
    }
    
    
    override func layoutSubviews() {
        // Subclass should override to calculate size of itself, and arrange subviews.
        fatalError()
    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        return nil
//    }
}
