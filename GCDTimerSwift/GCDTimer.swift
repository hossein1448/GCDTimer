//
//  File.swift
//  GCDTimer
//
//  Created by Hossein on 2/3/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

import Foundation

protocol GCDTimerProtocol: class {
    
    /*!
     * @discussion Timeout date time interval.
     */
    var timeoutDate: TimeInterval { get }
    /*!
     * @discussion Remaining time in second.
     * @return Remaining time to next timer fire call.
     */
    var remainingTime: TimeInterval { get }
    
    /*!
     * @discussion Provide an instance of GCDTimer.
     * @param timeout The number of seconds between firings of the timer.
     * @param timerRepeat If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
     * @param completion The execution body of the timer.
     * @param queue A dispatch_queue for executing the completion body.
     * @return An instance of GCDTimer with given values.
     */
    init!(timeout: TimeInterval,
          repeat timerRepeat: Bool,
          completion: (() -> Void)!,
          queue: DispatchQueue!)
    /*!
     * @discussion Start GCDtimer.
     */
    func start()
    /*!
     * @discussion fire the execution body (completion) and invalidate the timer.
     */
    func fireAndInvalidate()
    /*!
     * @discussion Invalidate the timer.
     */
    func invalidate()
    /*!
     * @discussion Clarify the status of timer whether is scheduled or not.
     * @return a bool value of timer schedule status
     */
    func isScheduled() -> Bool
    /*!
     * @discussion Reschedule the timer with new timeout value.
     * @param timeout New timeout value
     */
    func resetTimeout(_ timeout: TimeInterval)
    /*!
     * @discussion Pause the timer, store the remaining time and wait for calling the resume(). after first round, the timer timeout value calculated like the original.
     * @return Clarify the timer is pausable or not.
     */
    func pause() -> Bool
    /*!
     * @discussion Resume the timer with remaining timeInterval which is stored after pause().
     * @return Clarify the timer is resumable or not.
     */
    func resume() -> Bool
}

class GCDTimer: GCDTimerProtocol {
    private(set) var timeoutDate: TimeInterval
    private var timeout: TimeInterval
    private var pauseTimeInterval: TimeInterval?
    private var timeoutAfterResume: TimeInterval?
    private var timerRepeat: Bool
    private var completion: (() -> Void)
    private var queue: DispatchQueue
    private var timer: DispatchSourceTimer?
    var remainingTime: TimeInterval {
        guard timeoutDate > TimeInterval(Float.ulpOfOne) else {
            return Double.greatestFiniteMagnitude
        }
        return timeoutDate - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)
    }
    private var isPaused: Bool {
        guard let pauseTimeInterval = pauseTimeInterval, pauseTimeInterval > 0 else {
            return false
        }
        return true
    }
    
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
            if self?.timerRepeat == true,
                let timeout = self?.timeoutAfterResume,
                timeout > 0 {
                self?.resetTimeout(timeout)
            }
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
        timeoutAfterResume = 0
        guard timer != nil else {
            return
        }
        timer?.cancel()
        timer = nil
    }
    
    func isScheduled() -> Bool {
        return isPaused || timer != nil
    }
    
    func resetTimeout(_ timeout: TimeInterval) {
        invalidate()
        self.timeout = timeout
        start()
    }
    
    func pause() -> Bool {
        guard !isPaused else {
            return false
        }
        let pauseInterval = remainingTime
        invalidate()
        pauseTimeInterval = pauseInterval
        return pauseInterval > TimeInterval(Float.ulpOfOne)
    }
    
    func resume() -> Bool {
        guard isPaused else {
            return false
        }
        
        guard let pauseInterval = pauseTimeInterval, pauseInterval > TimeInterval(Float.ulpOfOne) else {
            fireAndInvalidate()
            return false
        }
        let nextTimeout = timeout
        resetTimeout(pauseInterval)
        timeoutAfterResume = nextTimeout
        return true
    }
}
