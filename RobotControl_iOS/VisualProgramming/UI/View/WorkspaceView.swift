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
    var connectionManager: ConnectionManager {
        return workspace.connectionManager
    }
    
    let viewBuilder: ViewBuilder
    
    let viewManager = ViewManager()
    
    var _blockViews = [String: BlockView]()
    
    init(workspace: Workspace, viewBuilder: ViewBuilder) {
        self.workspace = workspace
        self.viewBuilder = viewBuilder
        super.init(layoutConfig: viewBuilder.layoutConfig)
        
        connectionManager.delegate = self
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
                
                let savedTargetBlock = blockView.block.previousConnection?.targetBlock
                
                // 如果正在移动的方块有前置语句方块，则先断开与前置方块的连接
                connectionManager.disconnect(blockView.block.previousConnection!)
                
                // TODO:(#1) 可以只对BlockInputView执行，以优化速度
                //连接完之后重新绘制边框，以适应变化
                if savedTargetBlock != nil {
                    viewManager.findViewFor(savedTargetBlock!).layoutSubviews()
                }
                
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
            else  if recognizer.state == .ended {
                
                // 如果附近有可用连接，则连接上
                if let previousConnection = blockView.block.previousConnection  {
                    let availableConnection = connectionManager.findAvailableConnection(previousConnection)
                    if let availableConnection = availableConnection {
                        do {
                            try connectionManager.connect(previousConnection, anotherConnection: availableConnection)
                        }
                        catch {
                            fatalError()
                        }
                        
                        // TODO:(#1) 可以只对BlockInputView执行，以优化速度
                        //连接完之后重新绘制边框，以适应变化
                        viewManager.findViewFor(availableConnection.sourceBlock!).layoutSubviews()
                    }
                }
            }
        }
        
        self.layoutSubviews()
    }
}

extension WorkspaceView:  ConnectionManagerDelegate {
    func move(blockGroup: BlockGroup, withOffsetFrom from: Connection, to: Connection) {
        let toPosition = to.workspacePosition()
        let fromPosition = from.workspacePosition()
        let offset = CGPoint(x: toPosition.x - fromPosition.x, y: toPosition.y - fromPosition.y)
        
        for block in blockGroup.blocks {
            let blockView = viewManager.findViewFor(block)
            let origin = blockView.frame.origin
            blockView.frame.origin = CGPoint(x: origin.x + offset.x, y: origin.y + offset.y)
        }
    }
}
