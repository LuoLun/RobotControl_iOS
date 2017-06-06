//
//  BlockGroup.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockGroup: NSObject {

    var blocks = [String: Block]()
    var rootBlock: Block
    
    init(rootBlock: Block) {
        self.rootBlock = rootBlock
        super.init()
        blocks[rootBlock.uuid] = rootBlock
    }
    
}
