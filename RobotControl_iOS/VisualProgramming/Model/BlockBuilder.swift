//
//  BlockBuilder.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockBuilder: NSObject {
    
    let hasPreviousConnection: Bool
    let hasNextConnection: Bool
    
    init(hasPreviousConnection: Bool, hasNextConnection: Bool) {
        self.hasPreviousConnection = hasPreviousConnection
        self.hasNextConnection = hasNextConnection
        super.init()
    }
    
    func buildBlock() -> Block {
        let previousConnection = hasPreviousConnection ? Connection(category: .previous) : nil
        let nextConnection = hasNextConnection ? Connection(category: .next) : nil
        
        let block = Block(uuid: nil, previousConnection: previousConnection, nextConnection: nextConnection)
        previousConnection?.sourceBlock = block
        nextConnection?.sourceBlock = block
        
        block.blockGroup = BlockGroup(rootBlock: block)
        block.blockGroup?.blocks.append(block)
        
        return block
    }
}
