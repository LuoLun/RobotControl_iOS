//
//  BlockFactory.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockFactory: NSObject {
    
    private(set) var _builders = [String: BlockBuilder]()
    var builderNames: [String] {
        return Array(_builders.keys)
    }
    
    init(json: Array<[String: Any]>, workspace: Workspace) throws {
        super.init()
        
        for blockJson in json {
            guard let name = blockJson["name"] as? String else {
                throw BlockJsonError("Name missed or has wrong format.")
            }
            
            let builder = try Block.makeBuilder(json: blockJson)
            builder.workspace = workspace
            _builders[name] = builder
        }
    }
    
    func blockFor(name: String) throws -> Block {
        guard let block = _builders[name]?.buildBlock() else {
            throw BlockFactoryError("Can't find a block builder named \(name)")
        }
        return block
    }
}

class BlockFactoryError: NSError {
    init(_ description: String) {
        super.init(domain: "BlockFactoryError", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
