//
//  ToolboxView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol ToolboxViewDelegate: class {
    func toolboxDidTap(blockView: BlockView)
}

class ToolboxView: WorkspaceView {

    let blockXMargin: CGFloat = 20
    let blockYMargin: CGFloat = 20
    
    weak var toolboxViewDelegate: ToolboxViewDelegate?
    
    let _toolbox: Toolbox
    
    init(blockFactory: BlockFactory, viewBuilder: ViewBuilder) {
        _toolbox = Toolbox(blockFactory: blockFactory)
        super.init(workspace: _toolbox, viewBuilder: viewBuilder)
        
        _toolbox.load()
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addTrackingGesture(for blockView: BlockView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBlockView(_:)))
        blockView.addGestureRecognizer(tapGesture)
    }
    
    override func removeTrackingGesture(for blockView: BlockView?) {
        blockView?.gestureRecognizers?.forEach { blockView?.removeGestureRecognizer($0) }
    }

    func didTapBlockView(_ tapGesture: UITapGestureRecognizer) {
        toolboxViewDelegate!.toolboxDidTap(blockView: tapGesture.view as! BlockView)
    }
    
    override func layoutSubviews() {
        
        var x: CGFloat = blockXMargin / 2
        var lastMaxHeight: CGFloat = 0
        var y: CGFloat = blockYMargin / 2
        
        for view in subviews {
            guard let blockView = view as? DefaultBlockView else {
                continue
            }
            
            blockView.blockBackgroundBezierPath()
                        
            if blockView.frame.width + x > self.frame.width - blockXMargin / 2 {
                x = 0
                y += lastMaxHeight + blockYMargin
                lastMaxHeight = 0
            }
            
            assert(blockView.frame.width + x <= self.frame.width)
            
            blockView.frame.origin.x = x
            blockView.frame.origin.y = y
            
            x += blockView.frame.width + blockXMargin
            lastMaxHeight = max(lastMaxHeight, blockView.frame.height)
        }
    }
}
