//
//  HWDebounce.m
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/23.
//

#import "HWDebounce.h"

#pragma mark - HWDebounce

@interface HWDebounce()

@end

@implementation HWDebounce

#pragma mark - life cycle

- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWDebounceTaskBlock)taskBlock {
    return [self initWithInterval:interval
                          onQueue:dispatch_get_main_queue()
                        taskBlock:taskBlock];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock {
    return [self initWithDebounceMode:HWDebounceModeTrailing
                             interval:interval
                              onQueue:queue
                            taskBlock:taskBlock];
}

- (instancetype)initWithDebounceMode:(HWDebounceMode)debounceMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWDebounceTaskBlock)taskBlock {
    if (interval < 0) {
        interval = 0.1;
    }
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    
    switch (debounceMode) {
        case HWDebounceModeTrailing:
            self = [[HWDebounceTrailing alloc] initWithInterval:interval
                                                        onQueue:queue
                                                      taskBlock:taskBlock];
            break;
            
        case HWDebounceModeLeading:
            self = [[HWDebounceLeading alloc] initWithInterval:interval
                                                       onQueue:queue
                                                     taskBlock:taskBlock];
            break;
    }
    return self;
}

#pragma mark - public methods

- (void)call {
    NSAssert(1, @"This method should be overrided!");
}

- (void)invalidate {
    NSAssert(1, @"This method should be overrided!");
}

@end

#pragma mark - HWDebounceTrailing

@interface HWDebounceTrailing ()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWDebounceTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_block_t block;

@end

@implementation HWDebounceTrailing

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock {
    self = [super init];
    if (self) {
        _interval = interval;
        _taskBlock = taskBlock;
        _queue = queue;
    }
    return self;
}

- (void)call {
    if (self.block) {
        dispatch_block_cancel(self.block);
    }
    __weak typeof(self)weakSelf = self;
    self.block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        if (weakSelf.taskBlock) {
            weakSelf.taskBlock();
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), self.queue, self.block);
}

- (void)invalidate {
    self.taskBlock = nil;
    self.block = nil;
}

@end

#pragma mark - HWDebounceLeading
 
@interface HWDebounceLeading ()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWDebounceTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_block_t block;
@property (nonatomic, strong) NSDate *lastCallTaskDate;

@end

@implementation HWDebounceLeading

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock {
    self = [super init];
    if (self) {
        _interval = interval;
        _taskBlock = taskBlock;
        _queue = queue;
    }
    return self;
}

- (void)call {
    if (self.lastCallTaskDate) {
        if ([[NSDate date] timeIntervalSinceDate:self.lastCallTaskDate] > self.interval) {
            [self runTaskDirectly];
        }
    } else {
        [self runTaskDirectly];
    }
    self.lastCallTaskDate = [NSDate date];
}

- (void)invalidate {
    self.taskBlock = nil;
    self.block = nil;
}

- (void)runTaskDirectly {
    dispatch_async(self.queue, ^{
        if (self.taskBlock) {
            self.taskBlock();
        }
    });
}

@end

