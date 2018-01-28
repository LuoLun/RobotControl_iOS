//
//  BlockView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockView: LayoutView {

    let block: Block
    
    weak var workspaceView: WorkspaceView?

    init(block: Block, layoutConfig: LayoutConfig) {
        self.block = block
        super.init(layoutConfig: layoutConfig)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        var size = CGSize.zero
        var y: CGFloat = 0
        for subview in subviews {
            subview.layoutSubviews()
            subview.frame.origin.y = y
            subview.frame.origin.x = 0
            y += subview.frame.size.height
            size.height += subview.frame.size.height
            size.width = max(subview.frame.size.width, size.width)
        }
        self.frame.size = size
    }
}

extension BlockView: ConnectionDelegate {
    func workspacePositionOf(_ connection: Connection) -> CGPoint {
        return CGPoint.zero
    }
}
