//
//  FieldVariableView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldVariableView: FieldView {

    typealias VariableWithNs = (name: String, namespace: String)
    
    var sourceBlock: Block {
        return self.sourceInputView!.sourceBlockView!.block
    }
    
    var fieldVariable: FieldVariable? {
        return field as? FieldVariable
    }
    
    var variableManager: VariableManager {
        return self.sourceInputView!.sourceBlockView!.block.variableManager()
    }
    
    var variableManagers: Set<VariableManager> {
        return variableManagers(for: self.sourceInputView!.sourceBlockView!.block)
    }
    
    let _button: UIButton
    
    var selectedVariable: Variable? {
        get {
            return fieldVariable!._selectedVariable
        }
        set {
            fieldVariable!._selectedVariable = newValue
        }
    }
    
    override init(layoutConfig: LayoutConfig) {
        let button = UIButton(type: .roundedRect)
        _button = button
        super.init(layoutConfig: layoutConfig)
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        button.titleLabel!.font = layoutConfig.font
        button.setTitle(fieldVariable?.variableManager().variables.first?.name.appending("(\(fieldVariable!.variableManager().namespace()))") ?? "添加新变量", for: .normal)
        self.addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTapButton() {
        let alertController = UIAlertController(title: "选择变量", message: "请选择一个变量", preferredStyle: .actionSheet)
        
        let handler = { (action: UIAlertAction) -> Void in
            let title = action.title!
            let components = title.components(separatedBy: CharacterSet.init(charactersIn: "()"))
            let name = components[0]
            let namespace = components[1]            
            
            for variableManager in self.variableManagers {
                for variable in variableManager.variables {
                    if variable.name == name && namespace == variableManager.namespace() {
                        self.selectedVariable = variable
                        break
                    }
                }
            }
            self._button.setTitle(action.title, for: .normal)
        }
        
        let addVariableHandler = { (action: UIAlertAction) -> Void in
            self.addVariable()
        }
        let removeVariableHandler = { (action: UIAlertAction) -> Void in
            self.removeVariable()
        }
        
        var actions = self.variables(for: self.sourceBlock).map { UIAlertAction(title: $0.name + "(\($0.namespace))", style: .default, handler: handler) }
        actions.append(UIAlertAction(title: "添加新变量", style: .default, handler: addVariableHandler))
        actions.append(UIAlertAction(title: "删除变量", style: .destructive, handler: removeVariableHandler))
        actions.append(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actions.forEach{ alertController.addAction($0) }
        
        workspaceView!.presentAlertController(alertController)
    }
    
    func addVariable() {
        let addVariableAlert = UIAlertController(title: "添加变量", message: "请输入要添加的变量名称", preferredStyle: UIAlertControllerStyle.alert)
        var variableTextField: UITextField?
        addVariableAlert.addTextField(configurationHandler: { (textField: UITextField) in
            variableTextField = textField
        })
        addVariableAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action: UIAlertAction) in
            guard let variableName = variableTextField!.text else {
                return
            }
            if variableName == "" {
                return
            }
            self.variableManager.add(variableName)
        }))
        self.workspaceView!.presentAlertController(addVariableAlert)
    }
    
    func removeVariable() {
        let alertController = UIAlertController(title: "选择变量", message: "请选择一个变量", preferredStyle: .actionSheet)
        
        let handler = { (action: UIAlertAction) -> Void in
            let variableWithNs = self.variableNameAndNamespace(title: action.title!)
            let variableManager = self.variableManager(with: variableWithNs.namespace)!
            variableManager.remove(variableWithNs.name)
        }
        
        var actions = variableManager.variables.map{ UIAlertAction(title: $0.name, style: .default, handler: handler) }
        actions.append(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actions.forEach{ alertController.addAction($0) }
        
        workspaceView!.presentAlertController(alertController)
    }
    
    // MAKR: - Variables
    
    func variableManagers(for block: Block) -> Set<VariableManager> {
        var managers = Set<VariableManager>()
        var block: Block? = block
        while block != nil {
            if block!._variableManager != nil {
                managers.insert(block!._variableManager!)
            }
            block = block?.parentBlock()
        }
        managers.insert(workspaceView!.workspace.variableManager)
        return managers
    }
    
    func variables(for block: Block) -> [VariableWithNs] {
        var variables = [VariableWithNs]()
        for variableManager in self.variableManagers(for: block) {
            for variable in variableManager.variables {
                variables.append((name:variable.name, namespace: variableManager.namespace()))
            }
        }
        return variables
    }
    
    func variableNameAndNamespace(title: String) -> VariableWithNs {
        let components = title.components(separatedBy: CharacterSet.init(charactersIn: "()"))
        let name = components[0]
        let namespace = components[1]
        return (name: name, namespace: namespace)
    }
    
    func variableManager(with namespace: String) -> VariableManager? {
        for variableManager in variableManagers {
            if variableManager.namespace() == namespace {
                return variableManager
            }
        }
        return nil
    }
    
    // MAKR: - Layout subviews
    
    override func layoutSubviews() {
        _button.sizeToFit()
        
        var size = CGSize()
        size.width = contentEdgeInsets.left + _button.frame.size.width + contentEdgeInsets.right
        size.height = contentEdgeInsets.top + _button.frame.size.height + contentEdgeInsets.bottom
        _button.frame.origin = CGPoint(x: contentEdgeInsets.left, y: contentEdgeInsets.top)
        
        self.frame.size = size
    }
}
