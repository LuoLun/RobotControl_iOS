//
//  WorkspaceView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class WorkspaceView: UIView, WorkspaceListener {

    let workspace: Workspace
    let viewBuilder: ViewBuilder
    
    var _blockViews = [String: BlockView]()
    
    init(workspace: Workspace, viewBuilder: ViewBuilder) {
        self.workspace = workspace
        self.viewBuilder = viewBuilder
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Workspace listener
    
    func workspaceDidAddBlock(_ block: Block) {
        let blockView = viewBuilder.buildBlockView(block)
        self.addSubview(blockView)
        
        _blockViews[block.uuid] = blockView
    }
    
    func workspaceDidRemoveBlock(_ block: Block) {
        let blockView = _blockViews[block.uuid]
        blockView?.removeFromSuperview()
        _blockViews[block.uuid] = nil
    }

}
