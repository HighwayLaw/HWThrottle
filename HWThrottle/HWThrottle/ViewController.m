//
//  ViewController.m
//  Throttle
//
//  Created by highwayLiu on 2021/2/9.
//

#import "ViewController.h"
#import "HWThrottle.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, strong) HWThrottle *changeColorThrottle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.button];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.button setFrame:CGRectMake(0, 0, 100, 30)];
    self.button.center = self.view.center;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor grayColor];
        [_button setTitle:@"CHANGE" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _button.titleLabel.font = [UIFont systemFontOfSize:17];
        _button.clipsToBounds = YES;
        _button.layer.cornerRadius = 10;
        [_button addTarget:self action:@selector(changeBackgroundColorThrottle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)changeBackgroundColorThrottle {
    if (!self.changeColorThrottle) {
        self.changeColorThrottle = [[HWThrottle alloc] initWithThrottleMode:HWThrottleModeDebounce
                                                                   interval:1
                                                                    onQueue:dispatch_get_main_queue()
                                                                  taskBlock:^{
            [self changeBackgroundColor];
        }];
    }
    [self.changeColorThrottle call];
}

- (void)changeBackgroundColor {
    self.view.backgroundColor = self.colorArray.firstObject;
}

- (NSMutableArray *)colorArray {
    if (!_colorArray) {
        _colorArray = [NSMutableArray array];
        _colorArray = @[[UIColor cyanColor], [UIColor systemPinkColor], [UIColor yellowColor]].mutableCopy;
    }
    UIColor *removedColor = _colorArray.lastObject;
    [_colorArray removeLastObject];
    [_colorArray insertObject:removedColor atIndex:0];
    return _colorArray;
}

@end
