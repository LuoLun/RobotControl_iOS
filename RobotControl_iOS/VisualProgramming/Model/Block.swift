//
//  Block.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Block: NSObject {
    
    let uuid: String
    let previousConnection: Connection?
    let nextConnection: Connection?
    
    var directConnections: [Connection] {
        var connections = [Connection]()
        if let previousConnection = previousConnection {
            connections.append(previousConnection)
        }
        if let nextConnection = nextConnection {
            connections.append(nextConnection)
        }
        for input in inputs {
            if let blockInput = input as? BlockInput {
                connections.append(blockInput.connection)
            }
        }
        return connections
    }
    
    var blockGroup: BlockGroup?
    
    var inputs = [Input]()
    
    init(uuid: String?, previousConnection: Connection? = nil, nextConnection: Connection? = nil) {
        self.uuid = uuid ?? UUID().uuidString

        self.previousConnection = previousConnection
        self.nextConnection = nextConnection
//        workspacePosition = Workspace.Point(0, 0)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func copiedBlock() -> Block {
        let blockBuilder = BlockBuilder(hasPreviousConnection: previousConnection != nil, hasNextConnection: nextConnection != nil)
        return blockBuilder.buildBlock()
    }
    
    // MARK: Field
    
    func appendInput(_ input: Input) {
        inputs.append(input)
    }
}
