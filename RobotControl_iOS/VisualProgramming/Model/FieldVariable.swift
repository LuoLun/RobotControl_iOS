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
    
    override func codeValue() throws -> String? {
        guard let variable = _selectedVariable else {
            throw CompileError.VariableNotSelected
        }
        
        let namespace = variable.variableManager!.namespace().replacingOccurrences(of: ".", with: "_")
        let fullVariable = namespace + "_" + variable.name
        return fullVariable
    }
    
    override func serialize() throws -> String {
        guard let variable = _selectedVariable else {
            throw CompileError.VariableNotSelected
        }
        
        let namespace = variable.variableManager!.namespace()
        
        return "[\(namespace), \(variable.name)]"
    }
    
    override func deserialize(text: String) throws {
        let components = text.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).components(separatedBy: CharacterSet(charactersIn: ","))
        let namespace = components[0]
        let name = components[1]
        
        let allVariableManagers = variableManagers(for: sourceBlock!)
        var matchedVariableManager: VariableManager?
        for variableManager in allVariableManagers {
            if namespace == variableManager.namespace() {
                matchedVariableManager = variableManager
                break
            }
        }
        
        guard let variableManager = matchedVariableManager else {
            throw DeserializeError.namespaceNotFoundError(namespace: namespace)
        }
        
        // !!!: (#3) 因为这里只是为已经添加的变量还原，所以所有未使用的变量在反序列化的时候会消失
        variableManager.add(name)
    }
    
    // MARK: - 
    
    var variableManagers: Set<VariableManager> {
        return variableManagers(for: self.sourceBlock!)
    }
    
    func variableManagers(for block: Block) -> Set<VariableManager> {
        var managers = Set<VariableManager>()
        var block: Block? = block
        while block != nil {
            if block!._variableManager != nil {
                managers.insert(block!._variableManager!)
            }
            block = block?.parentBlock()
        }
        managers.insert(sourceBlock!.workspace!.variableManager)
        return managers
    }
}
