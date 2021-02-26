//
//  HWDebounce.h
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - public class

typedef NS_ENUM(NSUInteger, HWDebounceMode) {
    HWDebounceModeTrailing,        //invoking on the trailing edge of the timeout
    HWDebounceModeLeading,         //invoking on the leading edge of the timeout
};

typedef void(^HWDebounceTaskBlock)(void);

@interface HWDebounce : NSObject

/// Initialize a debounce object, the debounce mode is the default HWDebounceModeTrailing, the execution queue defaults to the main queue. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param interval debounce time interval, unit second
/// @param taskBlock the task to be debounced
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// Initialize a debounce object, the debounce mode is the default HWDebounceModeTrailing. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param interval debounce time interval, unit second
/// @param queue execution queue, defaults the main queue
/// @param taskBlock the task to be debounced
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// Initialize a debounce object. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param debounceMode the debounce mode, defaults HWDebounceModeTrailing
/// @param interval debounce time interval, unit second
/// @param queue execution queue, defaults the main queue
/// @param taskBlock the task to be debounced
- (instancetype)initWithDebounceMode:(HWDebounceMode)debounceMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWDebounceTaskBlock)taskBlock;


/// debouncing call the task
- (void)call;


/// When the owner of the HWDebounce object is about to release, call this method on the HWDebounce object first to prevent circular references
- (void)invalidate;

@end

#pragma mark - private classes

@interface HWDebounceTrailing : HWDebounce

@end

@interface HWDebounceLeading : HWDebounce

@end


NS_ASSUME_NONNULL_END
