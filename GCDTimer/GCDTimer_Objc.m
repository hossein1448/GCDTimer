//
//  GCDTimer.m
//  GCDTimer
//
//  Created by Hossein on 2/3/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

#import "GCDTimer_Objc.h"

#define weakify(var) __weak typeof(var) weak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = weak_##var; \
_Pragma("clang diagnostic pop")

@interface GCDTimerObjc ()

@property (nonatomic) dispatch_source_t timer;
@property (nonatomic, readwrite) NSTimeInterval timeoutDate;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic) NSTimeInterval pauseTimeInterval;
@property (nonatomic) bool repeat;
@property (nonatomic, copy) dispatch_block_t completion;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation GCDTimerObjc

@synthesize timeoutDate = _timeoutDate;
@synthesize timer = _timer;
@synthesize timeout = _timeout;
@synthesize repeat = _repeat;
@synthesize completion = _completion;
@synthesize queue = _queue;
@synthesize pauseTimeInterval = _pauseTimeInterval;

- (id)initWithTimeout:(NSTimeInterval)timeout repeat:(bool)timerRepeat completion:(dispatch_block_t)completion queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self != nil)
    {
        _timeoutDate = INT_MAX;
        _timeout = timeout;
        _repeat = timerRepeat;
        self.completion = completion;
        self.queue = queue;
    }
    return self;
}

- (void)dealloc
{
    if (_timer != nil)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)start
{
    _timeoutDate = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeout;
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeout * NSEC_PER_SEC)), _repeat ? (int64_t)(_timeout * NSEC_PER_SEC) : DISPATCH_TIME_FOREVER, 0);
    
    
    weakify(self)
    dispatch_source_set_event_handler(_timer, ^
                                      {
                                          strongify(self)
                                          if (self.completion)
                                              self.completion();
                                          if (!_repeat)
                                          {
                                              [self invalidate];
                                          }
                                      });
    dispatch_resume(_timer);
}

- (void)fireAndInvalidate
{
    if (self.completion) {
        weakify(self)
        dispatch_async(_queue, ^{
            strongify(self)
            self.completion();
        });
    }

    [self invalidate];
}

- (void)invalidate
{
    _timeoutDate = 0;
    _pauseTimeInterval = 0;
    
    if (_timer != nil)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (bool)isScheduled
{
    return _timer != nil;
}

- (void)resetTimeout:(NSTimeInterval)timeout
{
    [self invalidate];
    
    _timeout = timeout;
    [self start];
}

- (bool)pause {
    if (_pauseTimeInterval > 0) {
        return false;
    }
    _pauseTimeInterval = [self remainingTime];
    [self invalidate];
    return _pauseTimeInterval > FLT_EPSILON;
}

- (bool)resume {
    if (_pauseTimeInterval == 0) {
        return false;
    }
    if (_pauseTimeInterval < FLT_EPSILON) {
        [self fireAndInvalidate];
        return false;
    }
    [self resetTimeout:_pauseTimeInterval];
    return true;
}

- (NSTimeInterval)remainingTime
{
    if (_timeoutDate < FLT_EPSILON)
        return DBL_MAX;
    else
        return _timeoutDate - (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
}

@end
