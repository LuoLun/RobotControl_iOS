//
//  BlocklyViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlocklyCompilerViewController: UIViewController {
    
    var _toolboxView: ToolboxView?
    var _workspace: Workspace?
    var _viewBuilder: ViewBuilder?
    var _blockFactory: BlockFactory?
    var _compiler: Compiler?
    
    var _toolboxButton: UIButton?
    var _compileButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        let layoutConfig = LayoutConfig()
        
        let workspace = Workspace()
        _workspace = workspace
        let workspaceView = WorkspaceView(workspace: workspace, viewBuilder: ViewBuilder(layoutConfig: layoutConfig))
        workspaceView.delegate = self
        workspaceView.viewBuilder.workspaceView = workspaceView
        _viewBuilder = workspaceView.viewBuilder
        
        workspaceView.frame = self.view.frame
        
        self.view.addSubview(workspaceView)
        
        let jsonFilePath = Bundle.main.path(forResource: "BlockDef", ofType: "json")
        var jsonString = ""
        var json = Array<[String: Any]>()
        var blockFactory: BlockFactory?
        do {
            jsonString = try NSString(contentsOfFile: jsonFilePath!, encoding: String.Encoding.utf8.rawValue) as String
            let theJson = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.unicode)!, options: JSONSerialization.ReadingOptions.allowFragments) as? Array<[String: Any]>
            json = theJson!
            blockFactory = try BlockFactory(json: json, workspace: workspace)
            _blockFactory = blockFactory
        } catch {
            print("Cannot find json file.")
            fatalError()
        }
        
        initToolbox()
        initCompiler()
        initCompilerButton()
        
        do {
            let block1 = try blockFactory!.blockFor(name: "move")
            let block2 = try blockFactory!.blockFor(name: "if")
            
            workspace.addBlock(block1)
            workspace.addBlock(block2)
        }
        catch {
            print("Cannot find block builder name `move` and `if`")
            fatalError()
        }
    }
    
    // MARK: Toolbox
    
    func initToolbox() {
        let toolboxButton = UIButton(type: .roundedRect)
        _toolboxButton = toolboxButton
        toolboxButton.setTitle("打开工具箱", for: .normal)
        
        toolboxButton.addTarget(self, action: #selector(openToolxbox), for: .touchUpInside)
        
        toolboxButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toolboxButton)
        self.view.makeConstraintsEqualTo(toolboxButton, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), options: [.Top, .Right])
        
        _toolboxView = ToolboxView(blockFactory: _blockFactory!, viewBuilder: _viewBuilder!)
        _toolboxView?.toolboxViewDelegate = self
        
        self.view.addSubview(_toolboxView!)
        _toolboxView?.frame = self.view.frame
        
        _toolboxView?.isHidden = true
    }
    
    func openToolxbox() {
        _toolboxView?.isHidden = false
    }
    
    func closeToolbox() {
        _toolboxView?.isHidden = true
    }
    
    // MARK: Compiler
    
    func initCompiler() {
        do {
            let jsonPath = Bundle.main.path(forResource: "BlockCompileDef", ofType: "json")
            let jsonString = try NSString(contentsOfFile: jsonPath!, encoding: String.Encoding.utf8.rawValue)
            let json = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.allowFragments)
            let compiler = try Compiler(json: json as! [String : Any])
            _compiler = compiler
        }
        catch {
            fatalError()
        }
    }
    
    func initCompilerButton() {
        let button = UIButton(type: .roundedRect)
        _compileButton = button
        button.setTitle("编译", for: .normal)
        
        button.addTarget(self, action: #selector(compile), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.makeConstraintsEqualTo(self.view, edgeInsets: UIEdgeInsets.zero, options: .Right)
        
        NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: _toolboxButton, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func compile() {
        guard let values = _workspace?._blocks.values,
            let _ = Array(values)[0].blockGroup?.rootBlock else {
            print("工作空间中还没有语句方块，暂时不能编译")
                return
        }
        
        do {
            let code = try _compiler?.compile(workspace: _workspace!)
            print(String(describing: code))
        }
        catch let error {
            let alertController = UIAlertController(title: "编译错误", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension BlocklyCompilerViewController: WorkspaceViewDelegate {
    func presentAlertController(_ alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
}

extension BlocklyCompilerViewController: ToolboxViewDelegate {
    func toolboxDidTap(blockView: BlockView) {
        _workspace?.addBlock(blockView.block.copiedBlock())
        closeToolbox()
    }
}
