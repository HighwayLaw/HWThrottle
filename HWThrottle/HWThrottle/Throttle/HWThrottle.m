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

- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWThrottleTaskBlock)taskBlock {
    return [self initWithInterval:interval
                          onQueue:dispatch_get_main_queue()
                        taskBlock:taskBlock];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock {
    return [self initWithThrottleMode:HWThrottleModeLeading
                             interval:interval
                              onQueue:queue
                            taskBlock:taskBlock];
}

- (instancetype)initWithThrottleMode:(HWThrottleMode)throttleMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWThrottleTaskBlock)taskBlock {
    if (interval < 0) {
        interval = 0.1;
    }
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    
    switch (throttleMode) {
        case HWThrottleModeLeading: {
            self = [[HWThrottleLeading alloc] initWithInterval:interval
                                                       onQueue:queue
                                                     taskBlock:taskBlock];
            break;
        }
        case HWThrottleModeTrailing: {
            self = [[HWThrottleTrailing alloc] initWithInterval:interval
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

#pragma mark - HWThrottleLeading

@interface HWThrottleLeading()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWThrottleTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSDate *lastRunTaskDate;

@end

@implementation HWThrottleLeading

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

#pragma mark - HWThrottleTrailing

@interface HWThrottleTrailing()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) HWThrottleTaskBlock taskBlock;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSDate *lastRunTaskDate;
@property (nonatomic, strong) NSDate *nextRunTaskDate;

@end

@implementation HWThrottleTrailing

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
