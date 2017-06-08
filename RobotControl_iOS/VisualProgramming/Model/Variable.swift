//
//  Vairable.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Variable: NSObject {
    // 变量名
    internal(set) var name: String
    
    // 这个变量额变量管理器，相当于作用域
    weak var variableManager: VariableManager?
    
    init(name: String) {
        self.name = name
    }

    func codeNameWithNamespace() -> String {
        var codeName = variableManager!.namespace() + name
        codeName = codeName.replacingOccurrences(of: ".", with: "_")
        return codeName
    }
}
