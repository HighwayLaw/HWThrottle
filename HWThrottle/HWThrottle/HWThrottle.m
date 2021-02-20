//
//  HWThrottle.m
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/9.
//

#import "HWThrottle.h"


#pragma mark - HWThrottle

@interface HWThrottle()

@end

@implementation HWThrottle

#pragma mark - life cycle

- (instancetype)initWithThrottleMode:(HWThrottleMode)throttleMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWThrottleTaskBlock)taskBlock {
    NSAssert(interval > 0, @"interval must be greater than zero");
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    switch (throttleMode) {
        case HWThrottleModeFirstly: {
            self = [[HWThrottleFirstLy alloc] initWithInterval:interval
                                                       onQueue:queue
                                                     taskBlock:taskBlock];
            break;
        }
        case HWThrottleModeLast: {
            self = [[HWThrottleLast alloc] initWithInterval:interval
                                                    onQueue:queue
                                                  taskBlock:taskBlock];
            break;
        }
        case HWThrottleModeDebounce: {
            self = [[HWThrottleDebounce alloc] initWithInterval:interval
                                                        onQueue:queue
                                                      taskBlock:taskBlock];
            break;
        }
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

#pragma mark - HWThrottleFirstLy

@interface HWThrottleFirstLy()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWThrottleTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSDate *lastRunTaskDate;

@end

@implementation HWThrottleFirstLy

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock {
    self = [super init];
    if (self) {
        _interval = interval;
        _taskBlock = taskBlock;
        _queue = queue;
    }
    return self;
}

- (void)call {
    if (self.lastRunTaskDate) {
        if ([[NSDate date] timeIntervalSinceDate:self.lastRunTaskDate] > self.interval) {
            [self runTaskDirectly];
        }
    } else {
        [self runTaskDirectly];
    }
}

- (void)runTaskDirectly {
    dispatch_async(self.queue, ^{
        if (self.taskBlock) {
            self.taskBlock();
        }
        self.lastRunTaskDate = [NSDate date];
    });
}

- (void)invalidate {
    self.taskBlock = nil;
}

@end

#pragma mark - HWThrottleLast

@interface HWThrottleLast()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWThrottleTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSDate *lastRunTaskDate;
@property (nonatomic, strong) NSDate *nextRunTaskDate;

@end

@implementation HWThrottleLast

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock {
    self = [super init];
    if (self) {
        _interval = interval;
        _taskBlock = taskBlock;
        _queue = queue;
    }
    return self;
}

- (void)call {
    NSDate *now = [NSDate date];
    if (!self.nextRunTaskDate) {
        if (self.lastRunTaskDate) {
            if ([now timeIntervalSinceDate:self.lastRunTaskDate] > self.interval) {
                self.nextRunTaskDate = [NSDate dateWithTimeInterval:self.interval sinceDate:now];
            } else {
                self.nextRunTaskDate = [NSDate dateWithTimeInterval:self.interval sinceDate:self.lastRunTaskDate];
            }
        } else {
            self.nextRunTaskDate = [NSDate dateWithTimeInterval:self.interval sinceDate:now];
        }
        
        
        NSTimeInterval nextInterval = [self.nextRunTaskDate timeIntervalSinceDate:now];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(nextInterval * NSEC_PER_SEC)), self.queue, ^{
            if (self.taskBlock) {
                self.taskBlock();
            }
            self.lastRunTaskDate = [NSDate date];
            self.nextRunTaskDate = nil;
        });
    }
}

- (void)invalidate {
    self.taskBlock = nil;
}

@end

#pragma mark - HWThrottleDebounce

@interface HWThrottleDebounce()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWThrottleTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, strong) dispatch_block_t block;

@end

@implementation HWThrottleDebounce

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock {
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
