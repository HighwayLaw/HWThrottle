# HWThrottle
[函数节流（Throttle）和防抖（Debounce）解析及其OC实现](https://juejin.cn/post/6933952291142074376)

## 使用方法
按需直接将 HWThrottle和HWDebounce的.h及.m文件拖入工程即可。

## 一、Throttle和Debounce是什么
Throttle本是机械领域的概念，英文解释为：
>A valve that regulates the supply of fuel to the engine.

中文翻译成节流器，用以调节发动机燃料供应的阀门。在计算机领域，同样也引入了Throttle和Debounce概念，这两种技术都可用来降低函数调用频率，相似又有区别。对于连续调用的函数，尤其是触发频率密集、目标函数涉及大量计算时，恰当使用Throttle和Debounce可以有效提升性能及系统稳定性。

对于JS前端开发人员，由于无法控制DOM事件触发频率，在给DOM绑定事件的时候，常常需要进行Throttle或者Debounce来防止事件调用过于频繁。而对于iOS开发者来说，也许会觉得这两个术语很陌生，不过你很可能在不经意间已经用到了，只是没想过会有专门的抽象概念。举个常见的例子，对于UITableView，频繁触发reloadData函数可能会引起画面闪动、卡顿，数据源动态变化时甚至会导致崩溃，一些开发者可能会想方设法减少对reload函数的调用，不过对于复杂的UITableView视图可能会显得捉襟见肘，因为reloadData很可能“无处不在”，甚至会被跨文件调用，此时就可以考虑对reloadData函数本身做下降频处理。

下面通过概念定义及示例来详细解析对比下Throttle和Debounce，先看下二者在JS的Lodash库中的解释：

## Throttle
>Throttle enforces a maximum number of times a function can be called over time. For example, "execute this function at most once every 100 ms."

即，Throttle使得函数在规定时间间隔内（如100 ms），最多只能调用一次。

## Debounce
> Debounce enforces that a function not be called again until a certain amount of time has passed without it being called. For example, "execute this function only if 100 ms have passed without it being called."

即，Debounce可以将小于规定时间间隔（如100 ms）内的函数调用，归并成一次函数调用。

对于Debounce的理解，可以想象一下电梯的例子。你在电梯中，门快要关了，突然又有人要进来，电梯此时会再次打开门，直到短时间内没有人再进为止。虽然电梯上行下行的时间延迟了，但是优化了整体资源配置。

我们再以拖拽手势回调的动图展示为例，来直观感受下Throttle和Debounce的区别。每次“walk me”图标拖拽时，会产生一次回调。在动图的右上角，可以看到回调函数实际调用的次数。
### 1）正常回调：
![正常回调](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c91a25dace2441ea849cb35a2ca8678~tplv-k3u1fbpfcp-zoom-1.image) 

### 2）Throttle（Leading）模式下的回调：
![Throttle（Leading）模式下的回调](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e8867954dce40d3b9981079c0bf6749~tplv-k3u1fbpfcp-zoom-1.image)

### 3）Debounce（Trailing）模式下的回调：
![Debounce（Trailing）模式下的回调](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/08823bc7040845c09f1c6fbf55f89b17~tplv-k3u1fbpfcp-zoom-1.image)


## 二、应用场景
以下是几个典型的Throttle和Debounce应用场景。

### 1）防止按钮重复点击
为了防止用户重复快速点击，导致冗余的网络请求、动画跳转等不必要的损耗，可以使用Throttle的Leading模式，只响应指定时间间隔内的第一次点击。

### 2）滚动拖拽等密集事件
可以在UIScrollView的滚动回调didScroll函数里打日志观察下，调用频率相当高，几乎每移动1个像素都可能产生一次回调，如果回调函数的计算量偏大很可能会导致卡顿，此种情况下就可以考虑使用Throttle降频。

### 3）文本输入自动完成
假如想要实现，在用户输入时实时展示搜索结果，常规的做法是用户每改变一个字符，就触发一次搜索，但此时用户很可能还没有输入完成，造成资源浪费。此时就可以使用Debounce的Trailing模式，在字符改变之后的一段时间内，用户没有继续输入时，再触发搜索动作，从而有效节省网络请求次数。

### 4）数据同步
以用户埋点日志上传为例，没必要在用户每操作一次后就触发一次网络请求，此时就可以使用Debounce的Traling模式，在记录用户开始操作之后，且一段时间内不再操作时，再把日志merge之后上传至服务端。其他类似的场景，比如客户端与服务端版本同步，也可以采取这种策略。

在系统层面，或者一些知名的开源库里，也经常可以看到Throttle或者Debounce的身影。

### 5） GCD Background Queue
>Items dispatched to the queue run at background priority; the queue is scheduled for execution after all high priority queues have been scheduled and the system runs items on a thread whose priority is set for background status. Such a thread has the lowest priority and any disk I/O is throttled to minimize the impact on the system.

在dispatch的Background Queue优先级下，系统会自动将磁盘I/O操作进行Throttle，来降低对系统资源的耗费。

### 6）ASIHttpRequest及AFNetworking
```
- (void)handleNetworkEvent:(CFStreamEventType)type
{
    //...
    [self performThrottling];
    //...
}
```
```
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay;
```

在弱网环境下， 一个Packet一次传输失败的概率会升高，由于TCP是有序且可靠的，前一个Packet不被ack的情况下，后面的Packet就要等待，所以此时如果启用Network Throttle机制，减小写入数据量，反而会提升网络请求的成功率。

## 三、iOS实现
理解了Throttle和Debounce的概念后，在单个业务场景中实现起来是很容易的事情，但是考虑到其应用如此广泛，就应该封装成为业务无关的组件，减小重复劳动，提升开发效率。

前文提过，Throttle和Debounce在Web前端已经有相当成熟的实现，Ben Alman之前做过一个JQuery插件（不再维护），一年后Jeremy Ashkenas把它加入了underscore.js，而后又加入了[Lodash](https://lodash.com/docs/)。但是在iOS开发领域，尤其是对于Objective-C语言，尚且没有一个可靠、稳定且全面的第三方库。

杨萧玉曾经开源过一个[MessageThrottle](https://github.com/yulingtianxia/MessageThrottle)库，该库使用Objective-C的runtime与消息转发机制，使用非常便捷。但是这个库的缺点也比较明显，使用了大量的底层HOOK方法，系统兼容性方面还需要进一步的验证和测试，如果集成的项目中同时使用了其他使用底层runtime的方法，可能会产生冲突，导致非预期后果。另外该库是完全面向切面的，作用于全局且隐藏较深，增加了一定的调试成本。
为此笔者封装了一个新的实现[HWThrottle](https://github.com/HighwayLaw/HWThrottle)，并借鉴了Lodash的接口及实现方式，该库有以下特点：

**1）未使用任何runtime API，全部由顶层API实现；**

**2）每个业务场景需要使用者自己定义一个实例对象，自行管理生命周期，旨在把对项目的影响控制在最小范围；**

**3）区分Throttle和Debounce，提供Leading和Trailing选项。**


### Demo
下面展示了对按钮点击事件进行Throttle或Debounce的效果，click count表示点击按钮次数，call count表示实际调用目标事件的次数。

在leading模式下，会在指定时间间隔的开始处触发调用；Trailing模式下，会在指定时间间隔的末尾处触发调用。

#### 1) Throttle Leading
![Throttle Leading](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/838a98d40420456a8bd2016bf7b6ea60~tplv-k3u1fbpfcp-zoom-1.image)
#### 2) Throttle Trailing
![Throttle Trailing](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2e70d46d892843389bee8fb7366c32de~tplv-k3u1fbpfcp-zoom-1.image)
#### 3) Debounce Trailing
![Debounce Trailing](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0fb486372794d08b3eaddac992d920c~tplv-k3u1fbpfcp-zoom-1.image)
#### 4) Debounce Leading
![Debounce Leading](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e114e55651c40dd8e38f0c1fc0f8c2d~tplv-k3u1fbpfcp-zoom-1.image)

### 使用示例:
```
    if (!self.testThrottler) {
        self.testThrottler = [[HWThrottle alloc] initWithInterval:1 taskBlock:^{
           //do some heavy tasks
        }];
    }
    [self.testThrottler call];
```
由于使用到了block，**注意在Throttle或Debounce对象所有者即将释放时，即不再使用block时调用invalidate**，该方法会将持有的task block置空，防止循环引用。如果是在页面中使用Throttle或Debounce对象，可在disappear回调中调用invalidate方法。

```
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.testThrottler invalidate];
}
```

### 接口API：

**HWThrottle.h:**
```
#pragma mark - public class

typedef NS_ENUM(NSUInteger, HWThrottleMode) {
    HWThrottleModeLeading,          //invoking on the leading edge of the timeout
    HWThrottleModeTrailing,         //invoking on the trailing edge of the timeout
};

typedef void(^HWThrottleTaskBlock)(void);

@interface HWThrottle : NSObject

/// Initialize a throttle object, the throttle mode is the default HWThrottleModeLeading, the execution queue defaults to the main queue. Note that throttle is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param interval Throttle time interval, unit second
/// @param taskBlock The task to be throttled
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

/// Initialize a throttle object, the throttle mode is the default HWThrottleModeLeading. Note that throttle is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param interval Throttle time interval, unit second
/// @param queue Execution queue, defaults the main queue
/// @param taskBlock The task to be throttled
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWThrottleTaskBlock)taskBlock;

/// Initialize a debounce object. Note that debounce is for the same HWThrottle object, and different HWThrottle objects do not interfere with each other
/// @param throttleMode The throttle mode, defaults HWThrottleModeLeading
/// @param interval Throttle time interval, unit second
/// @param queue Execution queue, defaults the main queue
/// @param taskBlock The task to be throttled
- (instancetype)initWithThrottleMode:(HWThrottleMode)throttleMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWThrottleTaskBlock)taskBlock;


/// throttling call the task
- (void)call;


/// When the owner of the HWThrottle object is about to release, call this method on the HWThrottle object first to prevent circular references
- (void)invalidate;

@end
```
Throttle默认模式为Leading，因为实际使用中，多数的Throttle场景是在指定时间间隔的开始处调用，比如防止按钮重复点击时，一般会响应第一次点击，而忽略之后的点击。

**HWDebounce.h:**

```
#pragma mark - public class

typedef NS_ENUM(NSUInteger, HWDebounceMode) {
    HWDebounceModeTrailing,        //invoking on the trailing edge of the timeout
    HWDebounceModeLeading,         //invoking on the leading edge of the timeout
};

typedef void(^HWDebounceTaskBlock)(void);

@interface HWDebounce : NSObject

/// Initialize a debounce object, the debounce mode is the default HWDebounceModeTrailing, the execution queue defaults to the main queue. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param interval Debounce time interval, unit second
/// @param taskBlock The task to be debounced
- (instancetype)initWithInterval:(NSTimeInterval)interval
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// Initialize a debounce object, the debounce mode is the default HWDebounceModeTrailing. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param interval Debounce time interval, unit second
/// @param queue Execution queue, defaults the main queue
/// @param taskBlock The task to be debounced
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         onQueue:(dispatch_queue_t)queue
                       taskBlock:(HWDebounceTaskBlock)taskBlock;

/// Initialize a debounce object. Note that debounce is for the same HWDebounce object, and different HWDebounce objects do not interfere with each other
/// @param debounceMode The debounce mode, defaults HWDebounceModeTrailing
/// @param interval Debounce time interval, unit second
/// @param queue Execution queue, defaults the main queue
/// @param taskBlock The task to be debounced
- (instancetype)initWithDebounceMode:(HWDebounceMode)debounceMode
                            interval:(NSTimeInterval)interval
                             onQueue:(dispatch_queue_t)queue
                           taskBlock:(HWDebounceTaskBlock)taskBlock;


/// debouncing call the task
- (void)call;


/// When the owner of the HWDebounce object is about to release, call this method on the HWDebounce object first to prevent circular references
- (void)invalidate;

@end
```

Debounce默认模式为Trailing，因为实际使用中，多数的Debounce场景是在指定时间间隔的末尾处调用，比如监听用户输入时，一般是在用户停止输入后再触发调用。

### 核心代码：
**Throttle leading：**
```
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

```

**Throttle trailing:**
```
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

```

**Debounce trailing:**
```
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

```

**Debounce leading:**
```
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

- (void)runTaskDirectly {
    dispatch_async(self.queue, ^{
        if (self.taskBlock) {
            self.taskBlock();
        }
    });
}

- (void)invalidate {
    self.taskBlock = nil;
    self.block = nil;
}

```
## 四、总结
希望此篇文章能帮助你全面理解Throttle和Debounce的概念，赶快看看项目中有哪些可以用到Throttle或Debounce来提升性能的地方吧。

再次附上OC实现[HWThrottle](https://github.com/HighwayLaw/HWThrottle)，欢迎issue和讨论。

## 五、参考文章
[1][iOS编程中throttle那些事](https://www.jianshu.com/p/d2e1bcee406e)

[2][Objective-C Message Throttle and Debounce](http://yulingtianxia.com/blog/2017/11/05/Objective-C-Message-Throttle-and-Debounce/ "Objective-C Message Throttle and Debounce")

[3][Lodash Documentation](https://lodash.com/docs/)

