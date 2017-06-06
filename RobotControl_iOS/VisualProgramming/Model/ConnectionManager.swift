//
//  ConnectionManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol ConnectionManagerDelegate: class {
    func move(blockGroup: BlockGroup, withOffsetFrom from: Connection, to: Connection)
}

class ConnectionManager: NSObject {

    weak var delegate: ConnectionManagerDelegate?
    
    func connect(_ aConnection: Connection, anotherConnection: Connection) throws {
        
        guard aConnection.matchWith(anotherConnection) else {
            throw ConnectError.ConnectionMisMatch
        }
        
        switch aConnection.category {
        case .previous:
            if let targetBlock = aConnection.targetBlock {
                targetBlock.nextConnection?.targetBlock = nil
            }
            
            aConnection.targetBlock = anotherConnection.sourceBlock
            anotherConnection.targetBlock = aConnection.sourceBlock
            
            delegate!.move(blockGroup: aConnection.sourceBlock!.blockGroup!, withOffsetFrom: aConnection, to: anotherConnection)
            
            
            aConnection.sourceBlock!.blockGroup!.blocks.forEach { anotherConnection.sourceBlock!.blockGroup!.blocks[$0] = $1 }
            aConnection.sourceBlock!.blockGroup!.blocks.values.forEach {
                $0.blockGroup = anotherConnection.sourceBlock!.blockGroup!
            }
            
            aConnection.targetConnection = anotherConnection
            anotherConnection.targetConnection = aConnection
            
        case .next:
            try connect(anotherConnection, anotherConnection: aConnection)
            
        case .child:
            try connect(anotherConnection, anotherConnection: aConnection)
        }
    }
    
    func disconnect(_ connection: Connection) {
        guard let anotherConnection = connection.targetConnection else {
            return
        }
        
        switch connection.category {
        case .previous:
            
            let blockGroupOfLatter = BlockGroup(rootBlock: connection.sourceBlock!)
            
            var stack = [Block]()
            var block: Block? = connection.sourceBlock!
            while block != nil {
                blockGroupOfLatter.blocks[block!.uuid] = block
                for conn in block!.directConnections {
                    if conn.category == .previous {
                        continue
                    }
                    
                    if let targetBlock = conn.targetBlock {
                        stack.append(targetBlock)
                    }
                }
                
                block = stack.popLast() ?? nil
            }
            
            // 更新后面代码方块组的代码方块的组
            for block in blockGroupOfLatter.blocks.values {
                block.blockGroup = blockGroupOfLatter
                
                // 在前面的组中国年删去后面的组的方块
                anotherConnection.sourceBlock!.blockGroup?.blocks[block.uuid] = nil
            }
            
            connection.targetBlock = nil
            connection.targetConnection = nil
            
            anotherConnection.targetBlock = nil
            anotherConnection.targetConnection = nil
            
            
        default:
            disconnect(anotherConnection)
        }
    }
}

extension ConnectionManager {
    enum ConnectError: Error {
        case ConnectionMisMatch
    }
}
