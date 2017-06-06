//
//  WorkspaceView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class WorkspaceView: LayoutView, WorkspaceListener {

    let workspace: Workspace
    let viewBuilder: ViewBuilder
    
    let viewManager = ViewManager()
    
    var _blockViews = [String: BlockView]()
    
    init(workspace: Workspace, viewBuilder: ViewBuilder) {
        self.workspace = workspace
        self.viewBuilder = viewBuilder
        super.init(layoutConfig: viewBuilder.layoutConfig)
        
        workspace.connectionManager.delegate = self
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
        
        viewManager.register(block, for: blockView)
    }
    
    func workspaceDidRemoveBlock(_ block: Block) {
        let blockView = _blockViews[block.uuid]
        blockView!.removeFromSuperview()
        _blockViews[block.uuid] = nil
        
        blockView!.removeGestureRecognizer((blockView?.gestureRecognizers![0])!)
        
        viewManager.unregister(blockView!)
    }

    // Pan Gesture
    
    var panBeginPoint = CGPoint()
    var panBlockGruopBeginPoints = [Block: CGPoint]()
    
    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        print(recognizer.view)
        if recognizer.view is BlockView {
            let blockView = recognizer.view! as! BlockView
            
            if recognizer.state == .began {
                panBeginPoint = recognizer.location(in: self)
                panBlockGruopBeginPoints.removeAll()
                for block in blockView.block.blockGroup!.blocks {
                    panBlockGruopBeginPoints[block] = viewManager.findViewFor(block).frame.origin
                }
            }
            else if recognizer.state == .changed {
                let currentPanPoint = recognizer.location(in: self)
                let delta = CGPoint(x: currentPanPoint.x - panBeginPoint.x, y: currentPanPoint.y - panBeginPoint.y)
                
                for aBlock in blockView.block.blockGroup!.blocks {
                    let aBlockView = viewManager.findViewFor(aBlock)
                    aBlockView.frame.origin = CGPoint(x: panBlockGruopBeginPoints[aBlock]!.x + delta.x, y: panBlockGruopBeginPoints[aBlock]!.y + delta.y)
                }
            }
        }
        
        self.layoutSubviews()
    }
}

extension WorkspaceView:  ConnectionManagerDelegate {
    func move(blockGroup: BlockGroup, withOffsetFrom from: Connection, to: Connection) {
        let toPosition = to.delegate!.positionOf(to)
        let fromPosition = from.delegate!.positionOf(from)
        let offset = CGPoint(x: toPosition.x - fromPosition.x, y: toPosition.y - fromPosition.y)
        
        for block in blockGroup.blocks {
            let blockView = viewManager.findViewFor(block)
            let origin = blockView.frame.origin
            blockView.frame.origin = CGPoint(x: origin.x + offset.x, y: origin.y + offset.y)
        }
    }
}
