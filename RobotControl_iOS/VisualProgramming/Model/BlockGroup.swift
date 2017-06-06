//
//  BlockGroup.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockGroup: NSObject {

    private var _blocks = [String: Block]()
    var rootBlock: Block
    
    init(rootBlock: Block) {
        self.rootBlock = rootBlock
        super.init()
        _blocks[rootBlock.uuid] = rootBlock
    }
    
    var blocks: [Block] {
        return Array(_blocks.values)
    }
    
    func addBlock(_ block: Block) {
        _blocks[block.uuid] = block
    }
    
    func removeBlock(_ block: Block) {
        _blocks[block.uuid] = nil
    }
}
