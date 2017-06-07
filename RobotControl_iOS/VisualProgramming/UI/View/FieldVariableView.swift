//
//  FieldVariableView.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldVariableView: FieldView {

    var fieldVariable: FieldVariable? {
        return field as? FieldVariable
    }
    
    var variableManager: VariableManager? {
        return fieldVariable!.variableManager()
    }
    
    let _button: UIButton
    
    private(set) var selectedVariable: Variable?

    override init(layoutConfig: LayoutConfig) {
        let button = UIButton(type: .roundedRect)
        _button = button
        super.init(layoutConfig: layoutConfig)
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        button.setTitle(fieldVariable?.variableManager().variables.first?.name.appending("(\(fieldVariable!.variableManager().namespace()))") ?? "添加新变量", for: .normal)
        self.addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTapButton() {
        let alertController = UIAlertController(title: "选择变量", message: "请选择一个变量", preferredStyle: .actionSheet)
        
        let handler = { (action: UIAlertAction) -> Void in
            self.variableManager!.variables.forEach({ (variable: Variable) in
                if action.title! == variable.name {
                    self.selectedVariable = variable
                }
            })
            self._button.setTitle(action.title, for: .normal)
        }
        
        let addVariableHandler = { (action: UIAlertAction) -> Void in
            self.addVariable()
        }
        let removeVariableHandler = { (action: UIAlertAction) -> Void in
            self.removeVariable()
        }
        
        var actions = variableManager!.variables.map { UIAlertAction(title: $0.name, style: .default, handler: handler) }
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
            self.variableManager?.add(variableName)
        }))
        self.workspaceView!.presentAlertController(addVariableAlert)
    }
    
    func removeVariable() {
        let alertController = UIAlertController(title: "选择变量", message: "请选择一个变量", preferredStyle: .actionSheet)
        
        let handler = { (action: UIAlertAction) -> Void in
            let variableToRemove = action.title!
            self.variableManager?.remove(variableToRemove)
        }
        
        var actions = variableManager?.variables.map{ UIAlertAction(title: $0.name, style: .default, handler: handler) }
        actions?.append(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actions?.forEach{ alertController.addAction($0) }
        
        workspaceView!.presentAlertController(alertController)
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
