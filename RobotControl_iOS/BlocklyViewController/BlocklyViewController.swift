//
//  BlocklyViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class BlocklyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let workspace = Workspace()
        let workspaceView = WorkspaceView(workspace: workspace, viewBuilder: ViewBuilder())
        workspace.listener = workspaceView
        
        self.view.autolayout_addSubview(workspaceView)
        workspaceView.makeConstraintsEqualTo(self.view)
        
        let blockBuilder = BlockBuilder(hasPreviousConnection: true, hasNextConnection: true, hasChildConnection: false)
        
        let block1 = blockBuilder.buildBlock()
        let input1 = FieldInput()
        let field1 = FieldLabel(text: "demo")
        block1.inputs.append(input1)
        input1.appendField(field1)
        
        let block2 = blockBuilder.buildBlock()
        
        workspace.addBlock(block1)
        workspace.addBlock(block2)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
