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
        
        let blockBuilder = BlockBuilder(hasPreviousConnection: true, hasNextConnection: true)
        let block1 = blockBuilder.buildBlock()
        let block2 = blockBuilder.buildBlock()
        
        let connectionManager = ConnectionManager()
        let fakeConnectionManagerDelegate = FakeConnectionManagerDelegate()
        connectionManager.delegate = fakeConnectionManagerDelegate
        
        XCTAssertNoThrow(try connectionManager.connect(block1.previousConnection!, anotherConnection: block2.nextConnection!))
        
        XCTAssert(block2.nextConnection?.targetBlock == block1)
        XCTAssert(block1.previousConnection?.targetBlock == block2)
        
    }
    
    func testExample2() {
        let blockBuilder = BlockBuilder(hasPreviousConnection: true, hasNextConnection: true)
        let block1 = blockBuilder.buildBlock()
        let blockInput1 = BlockInput()
        block1.inputs.append(blockInput1)
        
        let block2 = blockBuilder.buildBlock()
        
        let connectionManager = ConnectionManager()
        let fakeConnectionManagerDelegate = FakeConnectionManagerDelegate()
        connectionManager.delegate = fakeConnectionManagerDelegate
        
        XCTAssertNoThrow(try connectionManager.connect(blockInput1.connection, anotherConnection: block2.previousConnection!))
        
        XCTAssert(block2.previousConnection!.targetBlock == block1)
        XCTAssert(block2.previousConnection!.targetConnection == blockInput1.connection)
        XCTAssert(blockInput1.connection.targetBlock == block2)
        XCTAssert(blockInput1.connection.targetConnection == block2.previousConnection!)
        
        connectionManager.disconnect(block2.previousConnection!)
        
        XCTAssert(block2.previousConnection!.targetBlock == nil)
        XCTAssert(block2.previousConnection!.targetConnection == nil)
        XCTAssert(blockInput1.connection.targetBlock == nil)
        XCTAssert(blockInput1.connection.targetConnection == nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

class FakeConnectionManagerDelegate: NSObject, ConnectionManagerDelegate {
    func move(blockGroup: BlockGroup, withOffsetFrom from: Connection, to: Connection) {
        
    }
    
    var layoutConfig: LayoutConfig = LayoutConfig()
}
