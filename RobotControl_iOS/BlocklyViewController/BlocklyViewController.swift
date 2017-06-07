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
        block2.inputs.append(input2)
        let field2 = FieldLabel(text: "demo2")
        input2.appendField(field2)
        let input3 = BlockInput()
        block2.inputs.append(input3)
        
        workspace.addBlock(block1)
        workspace.addBlock(block2)
        
        self.view.layoutSubviews()
                
        
         do {
            try workspace.connectionManager.connect(input3.connection, anotherConnection: block1.previousConnection!)
         }
         catch {
            fatalError()
         }
        assert(input3.connection.targetBlock == block1)
        assert(block1.previousConnection?.targetBlock == block2)
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
