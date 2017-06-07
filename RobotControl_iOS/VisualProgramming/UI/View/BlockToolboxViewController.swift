//
//  BlocklyViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockToolboxViewController: UIViewController {
    
    var _toolboxView: ToolboxView?
    var _workspace: Workspace?
    var _viewBuilder: ViewBuilder?
    var _blockFactory: BlockFactory?
    
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
        }
        
        initToolbox()
        
        do {
            let block1 = try blockFactory!.blockFor(name: "move")
            let block2 = try blockFactory!.blockFor(name: "if")
            
            workspace.addBlock(block1)
            workspace.addBlock(block2)
        }
        catch {
            print("Cannot find block builder name `move` and `if`")
        }
    }
    
    
    func initToolbox() {
        let toolboxButton = UIButton(type: .roundedRect)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension BlockToolboxViewController: WorkspaceViewDelegate {
    func presentAlertController(_ alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
}

extension BlockToolboxViewController: ToolboxViewDelegate {
    func toolboxDidTap(blockView: BlockView) {
        _workspace?.addBlock(blockView.block.copiedBlock())
        closeToolbox()
    }
}
