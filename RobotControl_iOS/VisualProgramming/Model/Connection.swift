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
    
protocol ConnectionPositionListener: class {
    // 没有连接和断开操作的情况下，需要更新连击的位置（比如说某个前赴语句方块嵌入了一个子语句方块）
    func updateWithoutOperation(connectionPosition: CGPoint, connection: Connection)
}
    
class Connection: NSObject {

    weak var delegate: ConnectionDelegate?
    weak var positionListener: ConnectionPositionListener?
    
    enum Category {
        case previous
        case next
        case child
    }
    
    let category: Category
    weak var sourceBlock: Block?
    var targetBlock: Block? {
        return targetConnection?.sourceBlock
    }
    
    weak var targetConnection: Connection?
    
    init(category: Category, sourceBlock: Block? = nil) {
        self.category = category
        super.init()
        self.sourceBlock = sourceBlock
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
