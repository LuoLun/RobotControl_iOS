//
//  WorkspaceSerializer.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import AEXML

class WorkspaceSerializer: NSObject {
    
    let NextElementName = "next"
    
    let _blockFactory: BlockFactory
    let _connectionManager: ConnectionManager
    let _workspace: Workspace
    
    init(blockFactory: BlockFactory, workspace: Workspace) {
        _blockFactory = blockFactory
        _connectionManager = workspace.connectionManager
        _workspace = workspace
        super.init()
    }
    
    // MARK: - 持久化
    func toElements(workspace: Workspace) throws -> [AEXMLElement] {
        var elements = [AEXMLElement]()
        for rootBlock in workspace.rootBlocks() {
            elements.append(try toElement(block: rootBlock))
        }
        return elements
    }
    
    func toElement(block: Block) throws -> AEXMLElement {
        let element = AEXMLElement(name: "block")
        element.attributes["name"] = block.name
        

        for field in block.allFields() {
            if let serializedValue = try field.serialize() {
                element.addChild(name: "field", value: serializedValue, attributes: ["name": field.name])
            }
        }
        
        // 先添加子block，最后再添加nextBlock
        for directConnection in block.directConnections {
            if directConnection.category == .child,
                let targetBlock = directConnection.targetBlock {
                let child = AEXMLElement(name: directConnection.sourceInput!.name)
                child.addChild(try toElement(block: targetBlock))
                element.addChild(child)
            }
        }
        
        if let nextBlock = block.nextConnection?.targetBlock {
            let nextElement = AEXMLElement(name: NextElementName)
            let nextBlockElement = try toElement(block: nextBlock)
            element.addChild(nextElement)
            nextBlockElement.addChild(nextBlockElement)
        }
        
        return element
    }
    
    func toString(workspace: Workspace) throws -> String {
        var text = ""
        
        let elements = try toElements(workspace: workspace)
        for element in elements {
            text += element.xmlCompact
        }
        
        return text
    }
    
    func toString(block: Block) throws -> String {
        let element = try toElement(block: block)
        return element.xmlCompact
    }
    
    // MARK: - Deserialize 反持久化
    
    @discardableResult
    func loadBlockToWorkspace(element: AEXMLElement, parentConnection: Connection? = nil, priorConnection: Connection? = nil) throws -> Block {
        
        if element.name != "block" {
            throw DeserializeError.BlockXMLError
        }
        
        guard let blockName = element.attributes["name"] else {
            throw DeserializeError.LackBlockNameError
        }
        
        let block = try _blockFactory.blockFor(name: blockName)
        _workspace.addBlock(block)
        
        // 如果是某个方块的子方块，就先连接，便于后面恢复变量数据
        // !!!: (#6)这中恢复变量管理器的方法有点混乱，更好的方法是把变量管理器分开来做序列话和反序列化
        if let theParentConnection = parentConnection {
            guard let connectingConnection = block.previousConnection else {
                throw DeserializeError.lackPreviousConnection(blockName: block.name)
            }
            try _connectionManager.connect(theParentConnection, anotherConnection: connectingConnection)
        }
        if let thePriorConnection = priorConnection {
            guard let connectingConnection = block.previousConnection else {
                throw DeserializeError.lackPreviousConnection(blockName: block.name)
            }
            try _connectionManager.connect(thePriorConnection, anotherConnection: connectingConnection)
        }
        
        for child in element.children {
            if child.name == "field" {
                guard let fieldName = child.attributes["name"] else {
                    throw DeserializeError.LackFieldNameError
                }
                
                try block.firstFieldWith(name: fieldName)?.deserialize(text: child.value!)
            } else if child.name == NextElementName {
                guard let nextBlockElement = child.children.first else {
                    throw DeserializeError.LackNextBlock
                }
                try loadBlockToWorkspace(element: child.children[0], parentConnection: nil, priorConnection: block.nextConnection)

                // !!!: (#6)因为现在使用提前连接的方法，所以不在这里连接，而是在前面的地方连接
                //                let nextBlock = try loadBlockToWorkspace(element: child.children[0], parentConnection: nil, priorConnection: block.nextConnection)
                //                let nextBlock = try loadBlockToWorkspace(element: child.children[0])
                //                try _connectionManager.connect(block.nextConnection!, anotherConnection: nextBlock.previousConnection!)
            } else {
                // 既不是field，也不是后继语句方块，就是blockInput
                
                // 寻找对应名字的input
                let blockInputs = block.allBlockInputs()
                var matchBlockInput: BlockInput?
                blockInputs.forEach({ (blockInput: BlockInput) in
                    if blockInput.name == child.name {
                        matchBlockInput = blockInput
                    }
                })
                
                // 如果找不到，则报错
                guard let blockInput = matchBlockInput else {
                    throw DeserializeError.unknownBlockInput(name: child.name)
                }
                
                // 生成子语句方块，并且连接到这个input
                
                guard let innerBlockElement = child.children.first else {
                    throw DeserializeError.LackNextBlock
                }
                
                try loadBlockToWorkspace(element: innerBlockElement, parentConnection: blockInput.connection)
                
                // !!!: (#6)因为现在使用提前连接的方法，所以不在这里连接，而是在前面的地方连接
//                let connectingBlock = try loadBlockToWorkspace(element: innerBlockElement, parentConnection: blockInput.connection)
//                let connectingBlock = try loadBlockToWorkspace(element: innerBlockElement)
//                guard let connectingConnection = connectingBlock.previousConnection else {
//                    throw DeserializeError.lackPreviousConnection(blockName: connectingBlock.name)
//                }
//                try _connectionManager.connect(blockInput.connection, anotherConnection: connectingConnection)
            }
            
        }
        return block
    }
    
    func loadToWorkspace(text: String) throws {
        // 读取之前先清空工作空间
        _workspace.rootBlocks().forEach { _workspace.removeBlockGroup($0.blockGroup!) }
        
        let document = try AEXMLDocument(xml: text)
        
        for element in document.children {
            try loadBlockToWorkspace(element: element)
        }
    }
}

//class SeializeError: RobotControlError {
//    public static let 
//}

class DeserializeError: RobotControlError {
    public static let BlockXMLError = DeserializeError("Block xml must have element name `block`", code: 1, domain: "DeserializeError")
    public static let LackBlockNameError = DeserializeError("Block xml must have attribute `name` standing for block name(type)", code: 2, domain: "DeserializeError")

    class func namespaceNotFoundError(namespace: String) -> DeserializeError {
        return DeserializeError("Namespace `\(namespace)` not found!", code: 3, domain: "DeserializeError")
    }
    
    public static let LackFieldNameError = DeserializeError("Field xml must have attribute `name` standing for block name(type)", code: 4, domain: "DeserializeError")
    
    class func unknownBlockInput(name: String) -> DeserializeError {
        return DeserializeError("Unknown block input name `\(name).`", code: 5)
    }
    
    class func lackPreviousConnection(blockName: String) -> DeserializeError {
        return DeserializeError("Block `\(blockName)` doesn't has preivous connection but has one in xml file.", code: 6)
    }
    
    public static let LackNextBlock = DeserializeError("Lack of next block xml.", code: 7)
}

