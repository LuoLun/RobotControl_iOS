//
//  BlockBuilder.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockBuilder: NSObject {
    
    let name: String
    let hasPreviousConnection: Bool
    let hasNextConnection: Bool
    
    var inputBuilders: [InputBuilder]?
    
    var workspace: Workspace?
    
    init(name: String, hasPreviousConnection: Bool, hasNextConnection: Bool) {
        self.hasPreviousConnection = hasPreviousConnection
        self.hasNextConnection = hasNextConnection
        self.name = name
        super.init()
    }
    
    func buildBlock() -> Block {
        let previousConnection = hasPreviousConnection ? Connection(category: .previous) : nil
        let nextConnection = hasNextConnection ? Connection(category: .next) : nil
        
        let block = Block(name: name, uuid: nil, previousConnection: previousConnection, nextConnection: nextConnection)
        previousConnection?.sourceBlock = block
        nextConnection?.sourceBlock = block
        
        block.blockGroup = BlockGroup(rootBlock: block)
        block.blockGroup?.addBlock(block)
        
        block.workspace = workspace
        
        for inputBuilder in inputBuilders! {
            let input = inputBuilder.buildInput()
            block.inputs.append(input)
        }
        
        return block
    }
}
