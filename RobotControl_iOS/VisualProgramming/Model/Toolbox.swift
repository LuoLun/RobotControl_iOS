//
//  Toolbox.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Toolbox: Workspace {
    
    let _blockFactory: BlockFactory
    
    init(blockFactory: BlockFactory) {
        _blockFactory = blockFactory
        super.init()
    }
    
    func load() {
        do {
            for name in _blockFactory.builderNames {
                addBlock(try _blockFactory.blockFor(name: name))
            }
        }
        catch {
            print("Unknown error.")
        }
    }

}
