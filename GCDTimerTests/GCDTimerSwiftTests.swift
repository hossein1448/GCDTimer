//
//  GCDTimerSwiftTests.swift
//  GCDTimerSwiftTests
//
//  Created by Hossein on 2/4/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

import XCTest
@testable import GCDTimerSwift
@testable import GCDTimer

class GCDTimerSwiftTests: XCTestCase {
    var timer: GCDTimer?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        timer = nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
