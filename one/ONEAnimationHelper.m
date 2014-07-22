//
//  ONEAnimationHelper.m
//  one
//
//  Created by zyy on 14-7-20.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEAnimationHelper.h"

@implementation ONEAnimationHelper

static ONEAnimationHelper *sharedSigleton;
static CGFloat pushPopDuration;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSigleton = [ONEAnimationHelper new];
        pushPopDuration = 0.4;
    }
}

+ (ONEAnimationHelper *)sharedAnimationHelper
{
    return sharedSigleton;
}

+ (void)pushViewController:(UIViewController *)destination toViewController:(UIViewController *)source
{
    // 设置source的目标位置
    CGRect sourceFrame = source.view.frame;
    sourceFrame.origin.x = -sourceFrame.size.width;
    
    // 先将destination放到source的右边
    CGRect destFrame = destination.view.frame;
    destFrame.origin.x = destination.view.frame.size.width;
    destination.view.frame = destFrame;
    
    // 设置destination的目标位置
    destFrame.origin.x = 0;
    [source.view.superview addSubview:destination.view];
    // 动画
    [UIView animateWithDuration:pushPopDuration
                     animations:^{
                         source.view.frame = sourceFrame;
                         destination.view.frame = destFrame;
                     }
                     completion:^(BOOL finished) {
                         [source presentViewController:destination animated:NO completion:nil];
                     }];
}

+ (void)popViewContorller:(UIViewController *)destination fromViewController:(UIViewController *)source
{
    // 设置source的目标位置
    CGRect sourceFrame = source.view.frame;
    sourceFrame.origin.x = 0;
    
    // 设置destination的目标位置
    CGRect destFrame = destination.view.frame;
    destFrame.origin.x = destFrame.size.width;
    
    // 动画
    [UIView animateWithDuration:pushPopDuration
                     animations:^{
                         source.view.frame = sourceFrame;
                         destination.view.frame = destFrame;
                     } completion:^(BOOL finished) {
//                         [source dismissViewControllerAnimated:YES completion:nil];
                     }];
}

@end
