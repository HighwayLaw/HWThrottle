//
//  HWThrottle.h
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - public

typedef NS_ENUM(NSUInteger, HWThrottleMode) {
    HWThrottleModeFirstly,      //执行最靠前发送的消息，后面发送的消息会被忽略
    HWThrottleModeLast,         //执行最靠后发送的消息，前面发送的消息会被忽略，执行时间会有延时
    HWThrottleModeDebounce,     //消息发送后延迟一段时间执行，如果这段时间内继续发送消息，则重新计时
};

typedef void(^HWThrottleTaskBlock)(void);

@interface HWThrottle : NSObject


/// 初始化一个throttle对象，注意节流是针对同一HWThrottle对象的，不同的HWThrottle对象之间互不干扰
/// @param throttleMode 选定节流模式
/// @param interval 节流时间间隔，单位 s
/// @param queue 执行任务的队列，不传默认主队列
/// @param taskBlock 要节流的任务block
- (instancetype)initWithThrottleMode:(HWThrottleMode)throttleMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWThrottleTaskBlock)taskBlock;


/// 节流调用任务
- (void)call;


/// HWThrottle对象所有者将要释放时，先对HWThrottle对象调用此方法，以防循环引用
- (void)invalidate;

@end

#pragma mark - private

@interface HWThrottleFirstLy : HWThrottle

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

@end

@interface HWThrottleLast : HWThrottle

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

@end

@interface HWThrottleDebounce : HWThrottle

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

@end

NS_ASSUME_NONNULL_END
