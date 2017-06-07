//
//  Block.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Block: NSObject {
    
    let name: String
    let uuid: String
    let previousConnection: Connection?
    let nextConnection: Connection?
    
    weak var workspace: Workspace?
    
    var _variableManager: VariableManager?
    
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
    
    var inputs = [Input]() {
        didSet {
            for input in inputs {
                input.sourceBlock = self
                if let blockInput = input as? BlockInput {
                    blockInput.connection.sourceBlock = self
                    
                    // 如果能够容纳子Block，则这个block需要有一个变量管理器
                    _variableManager = variableManager()
                    _variableManager!.delegate = self
                }
            }
        }
    }
    
    init(name: String, uuid: String?, previousConnection: Connection? = nil, nextConnection: Connection? = nil) {
        self.uuid = uuid ?? UUID().uuidString

        self.previousConnection = previousConnection
        self.nextConnection = nextConnection
//        workspacePosition = Workspace.Point(0, 0)
        self.name = name
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func copiedBlock() -> Block {
        let blockBuilder = BlockBuilder(name: name, hasPreviousConnection: previousConnection != nil, hasNextConnection: nextConnection != nil)
        return blockBuilder.buildBlock()
    }
    
    // MARK: Field

    // MARK: - Debug description
    
    func debugDescription(indent: Int) -> String {
        var debugString = ""
        
        let indentString = String(repeating: "\t", count: indent)
        debugString += indentString + debugDescription
        for conn in directConnections {
            switch conn.category {
            case .previous:
                continue
            case .next:
                if let targetBlock = conn.targetBlock {
                    debugString += targetBlock.debugDescription(indent: indent)
                }
            case .child:
                if let targetBlock = conn.targetBlock {
                    debugString += targetBlock.debugDescription(indent: indent + 1)
                }
            }
        }
        return debugString
    }
    
    // MARK: - Variable
    
    func parentBlock() -> Block? {
        var block: Block? = self
        while block != nil {
            if let targetCategory = block?.previousConnection?.targetConnection?.category,
                let targetBlock = block?.previousConnection?.targetBlock, targetCategory == .child {
                return targetBlock
            }
            
            block = block?.previousConnection?.targetBlock
        }
        return nil
    }
    
    func variableManager() -> VariableManager? {
        return _variableManager ?? parentBlock()?.variableManager() ?? workspace!.variableManager
    }
    
    func parentVariableManager() -> VariableManager? {
        return parentBlock()?.variableManager()
    }
}

extension Block: VariableManagerDelegate {
    func namespace() -> String {
        var block: Block? = self
        var namespace = ""
        while block != nil {
            namespace = block!.name + "." + namespace
            block = block?.parentBlock()
        }
        return namespace
    }
}
