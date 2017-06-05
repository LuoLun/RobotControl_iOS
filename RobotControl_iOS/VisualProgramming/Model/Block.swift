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
    let childConnection: Connection?
    
    var blockGroup: BlockGroup?
    
    var inputs = [Input]()
    
    init(uuid: String?, previousConnection: Connection? = nil, nextConnection: Connection? = nil, childConnection: Connection? = nil) {
        self.uuid = uuid ?? UUID().uuidString

        self.previousConnection = previousConnection
        self.nextConnection = nextConnection
        self.childConnection = childConnection
        workspacePosition = Workspace.Point(0, 0)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func copiedBlock() -> Block {
        let blockBuilder = BlockBuilder(hasPreviousConnection: previousConnection != nil, hasNextConnection: nextConnection != nil, hasChildConnection: childConnection != nil)
        return blockBuilder.buildBlock()
    }
    
    var workspacePosition: Workspace.Point
    
    // MARK: Field
    
    func appendInput(_ input: Input) {
        inputs.append(input)
    }
}
