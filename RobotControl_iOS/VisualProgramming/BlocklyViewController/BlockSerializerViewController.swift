//
//  BlockSerializerViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/8.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import AEXML

class BlockSerializerViewController: BlocklyCompilerViewController, UITableViewDelegate, UITableViewDataSource {
    
    var _workspaceSerializer: WorkspaceSerializer?
    var _serializeButton: UIButton?
    var _deserializeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSerializer()
        initSerializeButton()
        initDeserializeButton()
    }
    
    func initSerializer() {
        _workspaceSerializer = WorkspaceSerializer(blockFactory: _blockFactory!, workspace: _workspace!)
    }
    
    func initSerializeButton() {
        let button = UIButton(type: .roundedRect)
        _serializeButton = button
        
        button.setTitle("保存", for: .normal)
        button.addTarget(self, action: #selector(serialize), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        self.view.makeConstraintsEqualTo(button, edgeInsets: UIEdgeInsets.zero, options: .Right)
        NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: _compileButton, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func initDeserializeButton() {
        let button = UIButton(type: .roundedRect)
        _deserializeButton = button
        
        button.setTitle("读取", for: .normal)
        button.addTarget(self, action: #selector(deserialize), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        self.view.makeConstraintsEqualTo(button, edgeInsets: UIEdgeInsets.zero, options: .Right)
        NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: _serializeButton, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func serialize() {
        do {
            let text = try _workspaceSerializer!.toString(workspace: _workspace!)
            print(text)
            
            let alertController = UIAlertController(title: "请输入项目名字", message: "请输入项目名字", preferredStyle: .alert)
            var projectNameField: UITextField?
            alertController.addTextField(configurationHandler: { (textField: UITextField) in
                projectNameField = textField
            })
            alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (alertAction: UIAlertAction) in
                guard let projectName = projectNameField!.text else {
                    let alert = UIAlertController.messageAlert(title: "请重试", message: "项目名不能为空")
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                var projectDocument: AEXMLDocument?
                do {
                    projectDocument = try AEXMLDocument(xml: text)
                } catch {
                    fatalError()
                }
                
                do {
                    try ProjectManager.saveProject(document: projectDocument!, name: projectNameField!.text!, category: ProjectManager.Category.Blockly)
                } catch let error {
                    let alert = UIAlertController.messageAlert(title: "保存项目出错", message: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                }
                
                let successAlert = UIAlertController.messageAlert(title: "成功", message: "项目保存成功")
                self.present(successAlert, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        } catch let error {
            let alertController = UIAlertController(title: "持久化错误", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func deserialize() {
        let viewController = UITableViewController(style: .plain)
        viewController.tableView.delegate = self
        viewController.tableView.dataSource = self
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    func loadProjectNamed(name: String) {
        var project: ProjectManager.Project?
        do {
            project = try ProjectManager.loadProjectNamed(name, category: .Blockly)
        } catch let error {
            let alert = UIAlertController.messageAlert(title: "错误", message: "读取名为\(name)的项目出错\n\(error.localizedDescription)")
            self.present(alert, animated: true, completion: nil)
        }
        
        guard let theProject = project else {
            return
        }
        
        do {
            try _workspaceSerializer?.loadToWorkspace(text: theProject.document.xmlCompact)
        } catch let error {
            let alert = UIAlertController.messageAlert(title: "错误", message: "项目格式出错\n\(error.localizedDescription)")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 最后一项是“取消”
        return ProjectManager.projectNameList(category: .Blockly).count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        if indexPath.row < ProjectManager.projectNameList(category: .Blockly).count {
            cell!.textLabel!.text = ProjectManager.projectNameList(category: .Blockly)[indexPath.row]
        }
        else {
            cell!.textLabel!.text = "取消"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < ProjectManager.projectNameList(category: .Blockly).count {
            loadProjectNamed(name: ProjectManager.projectNameList(category: .Blockly)[indexPath.row])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
