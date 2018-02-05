//
//  GCDTimer.h
//  GCDTimer
//
//  Created by Hossein on 2/3/18.
//  Copyright © 2018 Hossein Asgari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

/*!
 * @discussion Timeout date time interval.
 */
@property (nonatomic, readonly) NSTimeInterval timeoutDate;
/*!
 * @discussion Provide an instance of GCDTimer.
 * @param timeout The number of seconds between firings of the timer.
 * @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 * @param completion The execution body of the timer.
 * @param queue A dispatch_queue for executing the completion body.
 * @return An instance of GCDTimer with given values.
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)repeats
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue;

/*!
 * @discussion Provide an instance of GCDTimer.
 * @param timeout The number of seconds between firings of the timer.
 * @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 * @param completion The execution body of the timer.
 * @param queue A dispatch_queue for executing the completion body.
 * @return An instance of GCDTimer with given values.
 */
+ (GCDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeout
                                    repeats:(BOOL)repeats
                                 completion:(dispatch_block_t)completion
                                       queue:(dispatch_queue_t)queue;

/*!
 * @discussion Start GCDtimer.
 */
- (void)start;

/*!
 * @discussion fire the execution body (completion) and invalidate the timer.
 */
- (void)fireAndInvalidate;

/*!
 * @discussion Invalidate the timer.
 */
- (void)invalidate;

/*!
 * @discussion Clarify the status of timer whether is scheduled or not.
 * @return a bool value of timer schedule status
 */
- (bool)isScheduled;

/*!
 * @discussion Reschedule the timer with new timeout value.
 * @param timeout New timeout value
 */
- (void)resetTimeout:(NSTimeInterval)timeout;

/*!
 * @discussion Pause the timer, store the remaining time and wait for calling the resume(). after first round, the timer timeout value calculated like the original.
 * @return Clarify the timer is pausable or not.
 */
- (bool)pause;

/*!
 * @discussion Resume the timer with remaining timeInterval which is stored after pause().
 * @return Clarify the timer is resumable or not.
 */
- (bool)resume;

/*!
 * @discussion Remaining time in second.
 * @return Remaining time to next timer fire call.
 */
- (NSTimeInterval)remainingTime;

@end
