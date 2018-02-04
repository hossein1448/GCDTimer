//
//  GCDTimerInterface.h
//  GCDTimer
//
//  Created by Hossein on 2/3/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCDTimer

@property (nonatomic, readonly) NSTimeInterval timeoutDate;

- (id)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)timerRepeat
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue;

- (void)start;
- (void)fireAndInvalidate;
- (void)invalidate;
- (bool)isScheduled;
- (void)resetTimeout:(NSTimeInterval)timeout;
- (bool)pause;
- (bool)resume;
- (NSTimeInterval)remainingTime;

@end
