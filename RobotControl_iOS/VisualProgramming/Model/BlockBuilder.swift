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
    let hasChildConnection: Bool
    
    init(hasPreviousConnection: Bool, hasNextConnection: Bool, hasChildConnection: Bool) {
        self.hasPreviousConnection = hasPreviousConnection
        self.hasNextConnection = hasNextConnection
        self.hasChildConnection = hasChildConnection
        super.init()
    }
    
    func buildBlock() -> Block {
        let previousConnection = hasPreviousConnection ? Connection(category: .previous) : nil
        let nextConnection = hasNextConnection ? Connection(category: .next) : nil
        let childConnection = hasChildConnection ? Connection(category: .child) : nil
        
        let block = Block(uuid: nil, previousConnection: previousConnection, nextConnection: nextConnection, childConnection: childConnection)
        previousConnection?.sourceBlock = block
        nextConnection?.sourceBlock = block
        childConnection?.sourceBlock = block
        
        return block
    }
}
