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
        workspaceView.viewBuilder.workspaceView = workspaceView
        
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
        
        let block3 = blockBuilder.buildBlock()
        let input4 = FieldInput()
        block3.inputs.append(input4)
        let field4 = FieldLabel(text: "demo3")
        input4.appendField(field4)
        
        for i in 0..<10 {
            let block = blockBuilder.buildBlock()
            let input = FieldInput()
            block.inputs.append(input)
            let field = FieldLabel(text: "auto_gen\(i)")
            input.appendField(field)
            workspace.addBlock(block)
        }
        
        workspace.addBlock(block1)
        workspace.addBlock(block2)
        workspace.addBlock(block3)
        
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
