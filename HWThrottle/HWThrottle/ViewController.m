//
//  ViewController.m
//  Throttle
//
//  Created by highwayLiu on 2021/2/9.
//

#import "ViewController.h"
#import "HWThrottle.h"
#import "HWThrottleTestVC.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *nextPageButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.nextPageButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.nextPageButton setFrame:CGRectMake(0, 0, 100, 30)];
    self.nextPageButton.center = self.view.center;
}

- (UIButton *)nextPageButton {
    if (!_nextPageButton) {
        _nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextPageButton.backgroundColor = [UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1];
        [_nextPageButton setTitle:@"Next" forState:UIControlStateNormal];
        [_nextPageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextPageButton setTitleColor:[UIColor colorWithRed:65 / 255.0 green:162 / 255.0 blue:192 / 255.0 alpha:1] forState:UIControlStateHighlighted];
        _nextPageButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _nextPageButton.clipsToBounds = YES;
        _nextPageButton.layer.cornerRadius = 10;
        [_nextPageButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextPageButton;
}

- (void)goToNextPage {
    HWThrottleTestVC *vc = [[HWThrottleTestVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
