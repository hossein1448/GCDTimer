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
        timer = GCDTimer(timeout: 1.0, repeat: true, completion: {
            repeatCount+=1
            XCTAssertTrue(Thread.isMainThread, "callback is in main thread.")
            if repeatCount > 1 {
                XCTAssertTrue(repeatCount > 1, "callback repeat")
                expectation.fulfill()
            }
        }, queue: DispatchQueue.main)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 3)
    }
    
    func testStartTimerWithRepeatInCustomThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        var repeatCount = 0
        let queue = DispatchQueue(label: "com.GCDTimer")
        timer = GCDTimer(timeout: 1.0, repeat: true, completion: {
            repeatCount+=1
            XCTAssertTrue(!Thread.isMainThread, "callback is not in main thread.")
            if repeatCount > 1 {
                XCTAssertTrue(repeatCount > 1, "callback repeat")
                expectation.fulfill()
            }
        }, queue: queue)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 3)
    }
    
    func testStartTimerNoRepeatInMainThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        var repeatCount = 0
        timer = GCDTimer(timeout: 1.0, repeat: false, completion: {
            repeatCount+=1
            XCTAssertTrue(repeatCount == 1, "callback called just once")
            XCTAssertTrue(Thread.isMainThread, "callback is in main thread.")
            expectation.fulfill()
        }, queue: DispatchQueue.main)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 3)
    }
    
    func testStartTimerNoRepeatInCustomThread() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        let queue = DispatchQueue(label: "com.GCDTimer")
        timer = GCDTimer(timeout: 1.0, repeat: false, completion: {
            XCTAssertTrue(!Thread.isMainThread, "callback is not in main thread.")
            expectation.fulfill()
        }, queue: queue)
        
        timer?.start()
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testInvalidateTimer() {
        timer = GCDTimer(timeout: 1.0, repeat: false, completion: {
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        timer?.invalidate()
        XCTAssertFalse((timer?.isScheduled())!, "timer is invalidated.")
    }
    
    func testFireAndInvalidateTimer() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        timer = GCDTimer(timeout: 2.0, repeat: false, completion: {
            expectation.fulfill()
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        timer?.fireAndInvalidate()
        XCTAssertFalse((timer?.isScheduled())!, "timer is invalidated yet.")
        self.wait(for: [expectation], timeout: 3)
    }
    
    func testPauseTimer() {
        timer = GCDTimer(timeout: 2.0, repeat: false, completion: {
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        let isPaused = timer?.pause()
        XCTAssertTrue(isPaused!, "timer is paused.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in pause mode.")
    }
    
    func testSecondPauseTimer() {
        timer = GCDTimer(timeout: 2.0, repeat: false, completion: {
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        var isPaused = timer?.pause()
        XCTAssertTrue(isPaused!, "timer is paused.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in pause mode.")
        isPaused = timer?.pause()
        XCTAssertFalse(isPaused!, "timer can't be paused for second time.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in pause mode.")
    }
    
    func testResumeTimer() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        timer = GCDTimer(timeout: 2.0, repeat: false, completion: {
            expectation.fulfill()
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        let isPaused = timer?.pause()
        XCTAssertTrue(isPaused!, "timer is paused.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in pause mode.")
        let isResumed = timer?.resume()
        XCTAssertTrue(isResumed!, "timer is resumed.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in resume mode.")
        self.wait(for: [expectation], timeout: 4)
    }
    
    func testSecondResumeTimer() {
        let expectation = XCTestExpectation(description: "timer expectaiton")
        timer = GCDTimer(timeout: 2.0, repeat: false, completion: {
            expectation.fulfill()
        }, queue: DispatchQueue.main)
        
        XCTAssertFalse((timer?.isScheduled())!, "timer is not scheduled yet.")
        timer?.start()
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled.")
        let isPaused = timer?.pause()
        XCTAssertTrue(isPaused!, "timer is paused.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in pause mode.")
        var isResumed = timer?.resume()
        XCTAssertTrue(isResumed!, "timer is resumed.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in resume mode.")
        isResumed = timer?.resume()
        XCTAssertFalse(isResumed!, "timer can't be resumed for second time.")
        XCTAssertTrue((timer?.isScheduled())!, "timer is scheduled in resume mode.")
        self.wait(for: [expectation], timeout: 4)
    }
}
