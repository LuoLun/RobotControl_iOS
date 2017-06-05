//
//  BlockGroup.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockGroup: NSObject {

    var blocks = [Block]()
    var rootBlock: Block
    
    init(rootBlock: Block) {
        self.rootBlock = rootBlock
        super.init()
    }
    
    func moveTo(_ point: Workspace.Point) {
        let moveOffset = Workspace.Point.offsetFor(rootBlock.workspacePosition, point)
        for block in blocks {
            block.workspacePosition.x += moveOffset.x
            block.workspacePosition.y += moveOffset.y
        }
    }
}
