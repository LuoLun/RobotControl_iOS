//
//  BlocklyViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlockFactoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        let layoutConfig = LayoutConfig()
        
        let workspace = Workspace()
        let workspaceView = WorkspaceView(workspace: workspace, viewBuilder: ViewBuilder(layoutConfig: layoutConfig))
        workspaceView.delegate = self
        workspaceView.viewBuilder.workspaceView = workspaceView
        
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
        } catch {
            print("Cannot find json file.")
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension BlockFactoryViewController: WorkspaceViewDelegate {
    func presentAlertController(_ alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
}
