//
//  LayoutView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class LayoutView: UIView {

    var layoutConfig: LayoutConfig
    
    init(layoutConfig: LayoutConfig) {
        self.layoutConfig = layoutConfig
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func runAnimatableCode(_ animate: Bool, code: @escaping () -> Void) {
        if animate {
            let duration = layoutConfig.viewAnimationDuration
            if duration > 0 {
                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut], animations: code, completion: nil)
            }
            return
        }
        code()
    }

}
