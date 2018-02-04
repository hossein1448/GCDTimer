//
//  File.swift
//  GCDTimer
//
//  Created by Hossein on 2/3/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

import Foundation

class GCDTimer {
    private(set) var timeoutDate: TimeInterval
    private var timeout: TimeInterval
    private var pauseTimeInterval: TimeInterval?
    private var timerRepeat: Bool
    private var completion: (() -> Void)
    private var queue: DispatchQueue
    private var timer: DispatchSourceTimer?
    
    required init!(timeout: TimeInterval,
                   repeat timerRepeat: Bool,
                   completion: (() -> Void)!,
                   queue: DispatchQueue!) {
        self.timeout = timeout
        self.timerRepeat = timerRepeat
        self.completion = completion
        self.queue = queue
        self.timeoutDate = TimeInterval(INT_MAX)
    }
    
    deinit {
        guard let timer = timer else {
            return
        }
        timer.cancel()
    }
    
    func start() {
        timeoutDate = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + timeout
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        if timerRepeat {
            timer?.schedule(deadline: .now() + timeout, repeating: timeout)
        }else {
            timer?.schedule(deadline: .now() + timeout)
        }
        
        timer?.setEventHandler(handler: { [weak self] in
            self?.completion()
        })
        timer?.resume()
    }
    
    func fireAndInvalidate() {
        queue.async { [weak self] in
            self?.completion()
        }
        
        invalidate()
    }
    
    func invalidate() {
        timeoutDate = 0
        pauseTimeInterval = 0
        guard timer != nil else {
            return
        }
        timer?.cancel()
        timer = nil
    }
    
    func isScheduled() -> Bool {
        return isPaused() || timer != nil
    }
    
    func resetTimeout(_ timeout: TimeInterval) {
        invalidate()
        self.timeout = timeout
        start()
    }
    
    func pause() -> Bool {
        guard !isPaused() else {
            return false
        }
        let pauseInterval = remainingTime()
        invalidate()
        pauseTimeInterval = pauseInterval
        return pauseInterval > TimeInterval(Float.ulpOfOne)
    }
    
    func resume() -> Bool {
        guard isPaused() else {
            return false
        }
        
        guard let pauseInterval = pauseTimeInterval, pauseInterval > TimeInterval(Float.ulpOfOne) else {
            fireAndInvalidate()
            return false
        }
        
        resetTimeout(pauseInterval)
        return true
    }
    
    func remainingTime() -> TimeInterval {
        guard timeoutDate > TimeInterval(Float.ulpOfOne) else {
            return Double.greatestFiniteMagnitude
        }
        return timeoutDate - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)
    }
    
    //MARK: Helpers
    private func isPaused() -> Bool {
        guard let pauseTimeInterval = pauseTimeInterval, pauseTimeInterval > 0 else {
            return false
        }
        return true
    }
}
