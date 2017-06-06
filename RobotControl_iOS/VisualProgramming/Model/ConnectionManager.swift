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
            
            anotherConnection.sourceBlock!.blockGroup!.blocks.append(contentsOf: aConnection.sourceBlock!.blockGroup!.blocks)
            aConnection.sourceBlock!.blockGroup!.blocks.forEach {
                $0.blockGroup = anotherConnection.sourceBlock!.blockGroup!
            }
            
        case .next:
            try connect(anotherConnection, anotherConnection: aConnection)
            
        case .child:
            try connect(anotherConnection, anotherConnection: aConnection)
        }
    }
    
}

extension ConnectionManager {
    enum ConnectError: Error {
        case ConnectionMisMatch
    }
}
