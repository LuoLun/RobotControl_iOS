//
//  VariableManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol VariableManagerDelegate: class {
    func namespace() -> String
}

class VariableManager: NSObject {
    
    weak var delegate: VariableManagerDelegate?
    
    var _variables = Set<Variable>()
    
    var variables: Set<Variable> {
        return _variables
    }
    
    var variableNames: Set<String> {
        // TODO: (#2) 可以通过注册变量名而不是每次生成，来优化效率
        var strings = Set<String>()
        variables.forEach { strings.insert($0.name) }
        return strings
    }
    
    @discardableResult
    func add(_ variableName:String) -> Bool {
        if variableNames.contains(variableName) {
            return false
        }
        
        let variable = Variable(name: variableName)
        variable.variableManager = self
        
        _variables.insert(variable)
        return true
    }
    
    func remove(_ variableName: String) {
        let index = _variables.index(where: { $0.name == variableName })
        _variables.remove(at: index!)
    }
    
    func namespace() -> String {
        return delegate!.namespace()
    }
}
