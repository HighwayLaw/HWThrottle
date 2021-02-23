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
    HWDebounceModeTrailing,        //执行最靠后发送的消息
    HWDebounceModeLeading,         //执行最靠前发送的消息
};

typedef void(^HWDebounceTaskBlock)(void);

@interface HWDebounce : NSObject

/// 初始化一个debounce对象，防抖模式为默认HWDebounceModeTrailing，执行队列默认主队列，注意防抖是针对同一HWDebounce对象的，不同的HWDebounce对象之间互不干扰
/// @param interval 防抖时间间隔，单位 s
/// @param taskBlock 要防抖的任务block
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// 初始化一个debounce对象，防抖模式为默认HWDebounceModeTrailing，注意防抖是针对同一HWDebounce对象的，不同的HWDebounce对象之间互不干扰
/// @param interval 防抖时间间隔，单位 s
/// @param queue 执行任务的队列，不传默认主队列
/// @param taskBlock 要防抖的任务block
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// 初始化一个debounce对象，注意防抖是针对同一HWDebounce对象的，不同的HWDebounce对象之间互不干扰
/// @param debounceMode 选定防抖模式
/// @param interval 防抖时间间隔，单位 s
/// @param queue 执行任务的队列，不传默认主队列
/// @param taskBlock 要防抖的任务block
- (instancetype)initWithDebounceMode:(HWDebounceMode)debounceMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWDebounceTaskBlock)taskBlock;


/// 防抖调用任务
- (void)call;


/// HWDebounce对象所有者将要释放时，先对HWDebounce对象调用此方法，以防循环引用
- (void)invalidate;

@end

#pragma mark - private classes

@interface HWDebounceTrailing : HWDebounce

@end

@interface HWDebounceLeading : HWDebounce

@end


NS_ASSUME_NONNULL_END
