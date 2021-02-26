//
//  HWThrottle.h
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - public class

typedef NS_ENUM(NSUInteger, HWThrottleMode) {
    HWThrottleModeLeading,          //invoking on the leading edge of the timeout
    HWThrottleModeTrailing,         //invoking on the trailing edge of the timeout
};

typedef void(^HWThrottleTaskBlock)(void);

@interface HWThrottle : NSObject

/// Initialize a throttle object, the throttle mode is the default HWThrottleModeLeading, the execution queue defaults to the main queue. Note that throttle is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param interval throttle time interval, unit second
/// @param taskBlock the task to be throttled
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

/// Initialize a throttle object, the throttle mode is the default HWThrottleModeLeading. Note that throttle is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param interval throttle time interval, unit second
/// @param queue execution queue, defaults the main queue
/// @param taskBlock the task to be throttled
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

/// Initialize a debounce object. Note that debounce is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param throttleMode the throttle mode, defaults HWThrottleModeLeading
/// @param interval throttle time interval, unit second
/// @param queue execution queue, defaults the main queue
/// @param taskBlock the task to be throttled
- (instancetype)initWithThrottleMode:(HWThrottleMode)throttleMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWThrottleTaskBlock)taskBlock;


/// throttling call the task
- (void)call;


/// When the owner of the HWThrottle object is about to release, call this method on the HWThrottle object first to prevent circular references
- (void)invalidate;

@end

#pragma mark - private classes

@interface HWThrottleLeading : HWThrottle

@end

@interface HWThrottleTrailing : HWThrottle

@end

NS_ASSUME_NONNULL_END
