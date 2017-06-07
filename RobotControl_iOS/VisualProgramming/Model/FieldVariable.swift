//
//  FieldVariable.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class FieldVariable: Field {
    
    func variableManager() -> VariableManager {
        return sourceBlock!.variableManager()!
    }
 
    override func copiedField() -> Field {
        let fieldVariable = FieldVariable()
        return fieldVariable
    }
}
