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
    var layoutConfig: LayoutConfig {get}
}

class ConnectionManager: NSObject {

    weak var delegate: ConnectionManagerDelegate?
    
    // MARK: - Tracking
    
    var _connections = Set<Connection>()
    
    func trackConnection(_ connection: Connection) {
        _connections.insert(connection)
    }
    
    func untrackConnection(_ connection: Connection) {
        _connections.remove(connection)
    }
    
    // MARK: - Operation
    
    func connect(_ aConnection: Connection, anotherConnection: Connection) throws {
        
        guard aConnection.matchWith(anotherConnection) else {
            throw ConnectError.ConnectionMisMatch
        }
        
        switch aConnection.category {
        case .previous:
            
            disconnect(anotherConnection)
            
            aConnection.targetConnection = anotherConnection
            anotherConnection.targetConnection = aConnection
            
            // 先把后面的Block与前面的Block连接在一起
            delegate!.move(blockGroup: aConnection.sourceBlock!.blockGroup!, withOffsetFrom: aConnection, to: anotherConnection)
            
            // 然后在前面的block的group添加后面的block，并为后面的block重新指向前面block的group
            aConnection.sourceBlock!.blockGroup!.blocks.forEach { anotherConnection.sourceBlock!.blockGroup!.addBlock($0)
            }
            aConnection.sourceBlock!.blockGroup!.blocks.forEach {
                $0.blockGroup = anotherConnection.sourceBlock!.blockGroup!
            }
            
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
                blockGroupOfLatter.addBlock(block!)
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
            for block in blockGroupOfLatter.blocks {
                block.blockGroup = blockGroupOfLatter
                
                // 在前面的组中国年删去后面的组的方块
                anotherConnection.sourceBlock!.blockGroup!.removeBlock(block)
            }
            
            connection.targetConnection = nil
            
            anotherConnection.targetConnection = nil
            
            
        default:
            disconnect(anotherConnection)
        }
    }
    
    // MARK: - Finding
    
    func findAvailableConnection(_ connection: Connection) -> Connection? {
        var nearest: Connection? = nil
        var nearestDistance:CGFloat = 0
        
        for aConnection in _connections {
            if aConnection == connection {
                continue
            }
            
            if aConnection.matchWith(connection) == false {
                continue
            }
            
            let distance = distanceBetween(connection, anotherConnection: aConnection)
            if distance < delegate!.layoutConfig.connectingDistance {
                if nearest == nil || nearestDistance > distance {
                    nearest = aConnection
                    nearestDistance = distance
                }
            }
        }
        
        return nearest
    }
    
    func distanceBetween(_ connection: Connection, anotherConnection: Connection) -> CGFloat {
        let pos1 = connection.workspacePosition()
        let pos2 = anotherConnection.workspacePosition()
        
        let delta = pow(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2), 0.5)
        return delta
    }
}

extension ConnectionManager {
    enum ConnectError: Error {
        case ConnectionMisMatch
    }
}
