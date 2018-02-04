//
//  GCDTimerSwiftTests.swift
//  GCDTimerSwiftTests
//
//  Created by Hossein on 2/4/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

import XCTest
@testable import GCDTimerObjc

class GCDTimerSwiftTests: XCTestCase {
    var timer: GCDTimer?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        timer = nil
        super.tearDown()
    }
    
    func testStartTimerWithRepeatInMainThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        var repeatCount = 0
        timer = GCDTimer(timeout: 2.0, repeat: true, completion: {
            repeatCount+=1
            if repeatCount > 1 {
                XCTAssertTrue(Thread.isMainThread, "callback is in main thread.")
                XCTAssertTrue(repeatCount > 1, "callback repeat")
                expectation.fulfill()
            }
        }, queue: DispatchQueue.main)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testStartTimerWithRepeatInCustomThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        var repeatCount = 0
        let queue = DispatchQueue(label: "com.GCDTimer")
        timer = GCDTimer(timeout: 2.0, repeat: true, completion: {
            repeatCount+=1
            if repeatCount > 1 {
                XCTAssertTrue(!Thread.isMainThread, "callback is not in main thread.")
                XCTAssertTrue(repeatCount > 1, "callback repeat")
                expectation.fulfill()
            }
        }, queue: queue)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 6)
    }
    
    func testStartTimerNoRepeatInMainThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        timer = GCDTimer(timeout: 2.0, repeat: true, completion: {
            XCTAssertTrue(Thread.isMainThread, "callback is in main thread.")
            expectation.fulfill()
        }, queue: DispatchQueue.main)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 10)
    }
    
    func testStartTimerNoRepeatInCustomThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        let queue = DispatchQueue(label: "com.GCDTimer")
        timer = GCDTimer(timeout: 2.0, repeat: true, completion: {
            XCTAssertTrue(!Thread.isMainThread, "callback is not in main thread.")
            expectation.fulfill()
        }, queue: queue)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 6)
    }
}
