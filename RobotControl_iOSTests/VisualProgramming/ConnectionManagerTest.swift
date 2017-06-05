//
//  ConnectionManager.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/5.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit
import XCTest

class ConnectionManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let blockBuilder = BlockBuilder(hasPreviousConnection: true, hasNextConnection: true, hasChildConnection: false)
        let block1 = blockBuilder.buildBlock()
        let block2 = blockBuilder.buildBlock()
        
        let connectionManager = ConnectionManager()
        XCTAssertNoThrow(try connectionManager.connect(block1.previousConnection!, anotherConnection: block2.nextConnection!))
        
        XCTAssert(block2.nextConnection?.targetBlock == block1)
        XCTAssert(block1.previousConnection?.targetBlock == block2)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
