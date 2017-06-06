	//
//  Connection.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol ConnectionDelegate: class {
    func workspacePositionOf(_ connection: Connection) -> CGPoint
}
    
class Connection: NSObject {

    weak var delegate: ConnectionDelegate?
    
    enum Category {
        case previous
        case next
        case child
    }
    
    let category: Category
    weak var sourceBlock: Block?
    weak var targetBlock: Block?
    
    weak var targetConnection: Connection?
    
    init(category: Category, sourceBlock: Block? = nil, targetBlock: Block? = nil) {
        self.category = category
        super.init()
        self.sourceBlock = sourceBlock
        self.targetBlock = targetBlock
    }
    
    func matchWith(_ connection: Connection) -> Bool {
        switch self.category {
        case .previous:
            return connection.category == .next || connection.category == .child
        case .next:
            return connection.category == .previous
        case .child:
            return connection.category == .previous
        }
    }
    
    func workspacePosition() -> CGPoint {
        return delegate!.workspacePositionOf(self)
    }
}
