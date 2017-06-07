//
//  Field.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/6.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Field: NSObject {
    weak var sourceInput: Input?
    weak var sourceBlock: Block?
    
    let name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    // MARK: - Subclass
    func copiedField() -> Field {
        // Subclass should override this method to copy a field.
        fatalError()
    }
    
    // MARK: - Compile
    
    func codeValue() throws -> String {
        fatalError()
    }
}
