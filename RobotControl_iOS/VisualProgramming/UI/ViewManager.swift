
//
//  ViewManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class ViewManager: NSObject {
    private var _views = [String: BlockView]()
    
    func register(_ block: Block, for blockView: BlockView) {
        _views[block.uuid] = blockView
    }
    
    func unregister(_ blockView: BlockView) {
        _views[blockView.block.uuid] = nil
    }
    
    func findViewFor(_ block: Block) -> BlockView {
        return _views[block.uuid]!
    }
}
