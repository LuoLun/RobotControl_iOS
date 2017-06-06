//
//  ConnectionManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject {

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
