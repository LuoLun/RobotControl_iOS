//
//  Workspace.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol WorkspaceListener {
    func workspaceDidAddBlock(_ block: Block)
    func workspaceDidRemoveBlock(_ block: Block)
}

class Workspace: NSObject {
    
    let variableManager: VariableManager
    
    var listener: WorkspaceListener?
    
    let connectionManager: ConnectionManager
    
    internal var _blocks = [String: Block]()
    
    func addBlock(_ block: Block) {
        _blocks[block.uuid] = block
        listener?.workspaceDidAddBlock(block)
        
        block.directConnections.forEach { connectionManager.trackConnection($0) }
    }
    
    func removeBlockGroup(_ blockGroup: BlockGroup) {
        for block in blockGroup.blocks {
            _blocks[block.uuid] = nil
            listener?.workspaceDidRemoveBlock(block)
            
            block.directConnections.forEach { connectionManager.untrackConnection($0) }

        }
    }
    
    override init() {
        connectionManager = ConnectionManager()
        variableManager = VariableManager()
        super.init()
        variableManager.delegate = self
    }
    
    func rootBlocks() -> Set<Block> {
        var rootBlocks = Set<Block>()
        for block in _blocks.values {
            rootBlocks.insert(block.blockGroup!.rootBlock)
        }
        return rootBlocks
    }
}

extension Workspace: VariableManagerDelegate {
    func namespace() -> String {
        return Block.GlobalNameSpace
    }
}

//extension Workspace {
//    class Point: NSObject {
//        var x, y: Float
//        
//        init(_ x: Float, _ y: Float) {
//            self.x = x
//            self.y = y
//        }
//        
//        class func offsetFor(_ point1: Point, _ point2: Point) -> Point {
//            return Point(point2.x - point1.x, point2.y - point1.y)
//        }
//    }
//}
