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
        
        self.edgesForExtendedLayout = []
        
        let layoutConfig = LayoutConfig()
        
        let workspace = Workspace()
        let workspaceView = WorkspaceView(workspace: workspace, viewBuilder: ViewBuilder(layoutConfig: layoutConfig))
        workspace.listener = workspaceView
        workspaceView.frame = self.view.frame
        
        self.view.addSubview(workspaceView)
        
        let blockBuilder = BlockBuilder(hasPreviousConnection: true, hasNextConnection: true)
        
        let block1 = blockBuilder.buildBlock()
        let input1 = FieldInput()
        let field1 = FieldLabel(text: "demo")
        block1.inputs.append(input1)
        input1.appendField(field1)
        
        let block2 = blockBuilder.buildBlock()
        let input2 = FieldInput()
        let field2 = FieldLabel(text: "demo2")
        block2.inputs.append(input2)
        input2.appendField(field2)
        
        workspace.addBlock(block1)
        workspace.addBlock(block2)
        
        self.view.layoutSubviews()
                
        
         do {
            try workspace.connectionManager.connect(block1.nextConnection!, anotherConnection: block2.previousConnection!)
         }
         catch {
            fatalError()
         }
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
