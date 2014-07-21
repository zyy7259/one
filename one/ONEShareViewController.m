//
//  ONEShareViewController.m
//  one
//
//  Created by zyy on 14-7-21.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEShareViewController.h"

@interface ONEShareViewController ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property UIViewController<ONEShareDelegate> *delegate;
@property (nonatomic) ONERecommendation *recommendation;
@property CGFloat duration;
@property CGFloat coverAlpha;

@end

@implementation ONEShareViewController

static ONEShareViewController *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSingleton = [ONEShareViewController new];
    }
}

+ (id)sharedShareViewControllerWithDelegate:(UIViewController<ONEShareDelegate> *)delegate
{
    sharedSingleton.delegate = delegate;
    return sharedSingleton;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([ONEShareViewController class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

# pragma mark 初始化：cover

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self connectButtons];
    
    self.duration = 0.25;
    self.coverAlpha = 0.5;
    self.coverView.alpha = 0.5;
}

# pragma mark divLoad：注册按钮事件

- (void)connectButtons
{
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark 显示分享

- (void)shareRecommendation:(ONERecommendation *)recommendation
{
    self.recommendation = recommendation;
    [self showShare];
}

- (void)shareApp
{
    [self showShare];
}

- (void)showShare
{
    // 设置遮盖层初始灰度
    self.coverView.alpha = self.coverAlpha;
    
    // 加载分享页面
    if (self.delegate.navigationController) {
        [self.delegate.navigationController.view addSubview:self.view];
    } else {
        [self.delegate.view addSubview:self.view];
    }
    
    // 设置分享界面的最终位置，使用动画加载分享界面
    CGRect frame =  self.shareView.frame;
    frame.origin.y = CGRectGetHeight(self.delegate.view.frame) - CGRectGetHeight(self.shareView.frame);

    [UIView animateWithDuration:self.duration
                     animations:^{
                         self.shareView.frame = frame;
                     } completion:nil];
}

# pragma mark 隐藏分享

- (IBAction)viewTapped:(id)sender
{
    [self cancelButtonTapped];
}

- (void)cancelButtonTapped
{
    [self hideShare];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(ONEShareViewControllerDidFinishDisplay:)]) {
            [self.delegate ONEShareViewControllerDidFinishDisplay:self];
        }
    }
}

- (void)hideShare
{
    // 设置分享界面最终位置，使用动画隐藏分享界面
    CGRect frame = self.shareView.frame;
    frame.origin.y = CGRectGetHeight(self.delegate.view.frame);
    
    // 隐藏遮盖层
    self.coverView.alpha = 0.0;
    
    [UIView animateWithDuration:self.duration
                     animations:^{
                         self.shareView.frame = frame;
                     } completion:^(BOOL finished) {
                         // 动画结束后，将分享页面从viewController移除
                         [self.view removeFromSuperview];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
