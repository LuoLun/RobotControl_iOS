//
//  FieldVariable.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldVariable: Field {
    
    internal var _selectedVariable: Variable?
    
    func variableManager() -> VariableManager {
        return sourceBlock!.variableManager()
    }
 
    override func copiedField() -> Field {
        let fieldVariable = FieldVariable(name: name)
        return fieldVariable
    }
    
    override func codeValue() throws -> String {
        guard let variable = _selectedVariable else {
            throw CompileError.VariableNotSelected
        }
        
        let namespace = variable.variableManager!.namespace().replacingOccurrences(of: ".", with: "_")
        let fullVariable = namespace + "_" + variable.name
        return fullVariable
    }
}

class CompileError: NSError {
    
    public static let VariableNotSelected = CompileError("Variable field has not been selectd.", code: 1)
    
    init(_ description: String, code: Int) {
        super.init(domain: "CompileError", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
