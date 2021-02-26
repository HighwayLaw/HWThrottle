//
//  HWDebounceTestVC.m
//  HWThrottle
//
//  Created by highwayLiu on 2021/2/23.
//

#import "HWDebounceTestVC.h"
#import "UIView+LayoutHelper.h"
#import "HWDebounce.h"

@interface HWDebounceTestVC ()

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectModeButton;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) HWDebounce *testDebouncer;
@property (nonatomic, assign) HWDebounceMode selectedMode;
@property (nonatomic, assign) NSUInteger clickCount;
@property (nonatomic, assign) NSUInteger callCount;

@end

@implementation HWDebounceTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedMode = HWDebounceModeTrailing;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.testButton];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.selectModeButton];
    [self.view addSubview:self.selectLabel];
    [self.view addSubview:self.showLabel];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.testButton setFrame:CGRectMake(0, 0, 150, 30)];
    self.testButton.center = self.view.center;
    [self.backButton setFrame:CGRectMake(self.testButton.x, self.testButton.maxY + 100, 150, 30)];
    [self.selectModeButton setFrame:CGRectMake(self.testButton.x, self.testButton.y - 30 - 20, 150, 30)];
    [self.selectLabel setFrame:CGRectMake(0, self.testButton.y - 30 - 20, (self.view.width - 150) / 2 - 5, 30)];
    [self.showLabel setFrame:CGRectMake(0, self.testButton.y - 100 - 30, self.view.width, 30)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.testDebouncer invalidate];
}

- (void)dealloc {
    //put breakpoint here to check whether there's a retain cycle here
    NSLog(@"");
}

#pragma mark - private methods

- (void)testDebounce {
    if (!self.testDebouncer) {
        self.testDebouncer = [[HWDebounce alloc] initWithDebounceMode:self.selectedMode
                                                             interval:1
                                                              onQueue:dispatch_get_main_queue()
                                                            taskBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callCount++;
                [self refreshCountLabel];
            });
        }];
    }
    [self.testDebouncer call];
    
    self.clickCount++;
    [self refreshCountLabel];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectMode {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak UIAlertController *bAlertVC = alertVC;
    void (^block)(UIAlertAction *action) = ^void(UIAlertAction *action){
        NSUInteger index = [bAlertVC.actions indexOfObject:action];
        self.selectedMode = index;
        [self.selectModeButton setTitle:[self nameForMode:self.selectedMode] forState:UIControlStateNormal];
        self.clickCount = 0;
        self.callCount = 0;
        [self refreshCountLabel];
        
        [self.testDebouncer invalidate];
        self.testDebouncer = [[HWDebounce alloc] initWithDebounceMode:self.selectedMode
                                                             interval:1
                                                              onQueue:dispatch_get_main_queue()
                                                            taskBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callCount++;
                [self refreshCountLabel];
            });
        }];
    };
    
    [alertVC addAction:[UIAlertAction actionWithTitle:[self nameForMode:HWDebounceModeTrailing]
                                                style:UIAlertActionStyleDefault
                                              handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:[self nameForMode:HWDebounceModeLeading]
                                                style:UIAlertActionStyleDefault
                                              handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (NSString *)nameForMode:(HWDebounceMode)mode {
    NSString *name = nil;
    switch (mode) {
        case HWDebounceModeTrailing:
            name = @"Trailing";
            break;
            
        case HWDebounceModeLeading:
            name = @"Leading";
            break;
    }
    return name;
}

- (UIColor *)colorForR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
}

- (void)refreshCountLabel {
    _showLabel.text = [NSString stringWithFormat:@"click count: %lu, call count: %lu", (unsigned long)self.clickCount, (unsigned long)self.callCount];
}

#pragma mark - settters & getters

- (UIButton *)testButton {
    if (!_testButton) {
        _testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _testButton.backgroundColor = [self colorForR:51 G:109 B:204];
        [_testButton setTitle:@"Click Me" forState:UIControlStateNormal];
        [_testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_testButton setTitleColor:[self colorForR:51 G:109 B:204] forState:UIControlStateHighlighted];
        _testButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _testButton.clipsToBounds = YES;
        _testButton.layer.cornerRadius = 10;
        [_testButton addTarget:self action:@selector(testDebounce) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [self colorForR:65 G:162 B:192];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setTitleColor:[self colorForR:65 G:162 B:192] forState:UIControlStateHighlighted];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _backButton.clipsToBounds = YES;
        _backButton.layer.cornerRadius = 10;
        [_backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)selectModeButton {
    if (!_selectModeButton) {
        _selectModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectModeButton.backgroundColor = [self colorForR:65 G:162 B:192];
        [_selectModeButton setTitle:[self nameForMode:self.selectedMode] forState:UIControlStateNormal];
        [_selectModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectModeButton setTitleColor:[self colorForR:65 G:162 B:192] forState:UIControlStateHighlighted];
        _selectModeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _selectModeButton.clipsToBounds = YES;
        _selectModeButton.layer.cornerRadius = 10;
        [_selectModeButton addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectModeButton;
}

- (UILabel *)selectLabel {
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] init];
        _selectLabel.text = @"Select Mode:";
        _selectLabel.textColor = [UIColor grayColor];
        _selectLabel.font = [UIFont systemFontOfSize:17];
        _selectLabel.textAlignment = NSTextAlignmentRight;
    }
    return _selectLabel;
}

- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] init];
        _showLabel.text = @"click count: 0, call count: 0";
        _showLabel.textColor = [UIColor grayColor];
        _showLabel.font = [UIFont boldSystemFontOfSize:20];
        _showLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _showLabel;
}


@end
