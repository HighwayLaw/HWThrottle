//
//  ViewController.m
//  Throttle
//
//  Created by highwayLiu on 2021/2/9.
//

#import "ViewController.h"
#import "HWThrottle.h"
#import "HWThrottleTestVC.h"
#import "HWDebounceTestVC.h"
#import "UIView+LayoutHelper.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *throttleButton;
@property (nonatomic, strong) UIButton *debounceButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.throttleButton];
    [self.view addSubview:self.debounceButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.throttleButton setFrame:CGRectMake(0, 0, 150, 40)];
    self.throttleButton.center = self.view.center;
    [self.debounceButton setFrame:CGRectMake(self.throttleButton.x, self.throttleButton.maxY + 30, 150, 40)];
}

- (UIButton *)throttleButton {
    if (!_throttleButton) {
        _throttleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _throttleButton.backgroundColor = [UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1];
        [_throttleButton setTitle:@"Test Throttle" forState:UIControlStateNormal];
        [_throttleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_throttleButton setTitleColor:[UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1] forState:UIControlStateHighlighted];
        _throttleButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _throttleButton.clipsToBounds = YES;
        _throttleButton.layer.cornerRadius = 10;
        [_throttleButton addTarget:self action:@selector(goToThrottlePage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _throttleButton;
}

- (UIButton *)debounceButton {
    if (!_debounceButton) {
        _debounceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _debounceButton.backgroundColor = [UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1];
        [_debounceButton setTitle:@"Test Debounce" forState:UIControlStateNormal];
        [_debounceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_debounceButton setTitleColor:[UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1] forState:UIControlStateHighlighted];
        _debounceButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _debounceButton.clipsToBounds = YES;
        _debounceButton.layer.cornerRadius = 10;
        [_debounceButton addTarget:self action:@selector(goToDebouncePage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _debounceButton;
}

- (void)goToThrottlePage {
    HWThrottleTestVC *vc = [[HWThrottleTestVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)goToDebouncePage {
    HWDebounceTestVC *vc = [[HWDebounceTestVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
