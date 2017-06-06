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
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        blockView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func workspaceDidRemoveBlock(_ block: Block) {
        let blockView = _blockViews[block.uuid]
        blockView?.removeFromSuperview()
        _blockViews[block.uuid] = nil
        
        blockView?.removeGestureRecognizer((blockView?.gestureRecognizers![0])!)
    }

    // Pan Gesture
    
    var panBeginPoint = CGPoint()
    var panBlockBeginPoint = CGPoint()
    
    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        print(recognizer.view)
        if recognizer.view is BlockView {
            let blockView = recognizer.view!
            
            if recognizer.state == .began {
                panBeginPoint = recognizer.location(in: self)
                panBlockBeginPoint = blockView.frame.origin
            }
            else if recognizer.state == .changed {
                let currentPanPoint = recognizer.location(in: self)
                let delta = CGPoint(x: currentPanPoint.x - panBeginPoint.x, y: currentPanPoint.y - panBeginPoint.y)
                blockView.frame.origin = CGPoint(x: panBlockBeginPoint.x + delta.x, y: panBlockBeginPoint.y + delta.y)
            }
        }
        
        self.layoutSubviews()
    }
}
