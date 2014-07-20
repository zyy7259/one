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

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSigleton = [ONEAnimationHelper new];
    }
}

+ (ONEAnimationHelper *)sharedAnimationHelper
{
    return sharedSigleton;
}

- (void)pushViewController:(UIViewController *)destination toViewController:(UIViewController *)source
{
    CGRect sourceFrame = source.view.frame;
    sourceFrame.origin.x = -sourceFrame.size.width;
    
    CGRect destFrame = destination.view.frame;
    destFrame.origin.x = destination.view.frame.size.width;
    destination.view.frame = destFrame;
    
    destFrame.origin.x = 0;
    [source.view.superview addSubview:destination.view];
    [UIView animateWithDuration:.4
                     animations:^{
                         source.view.frame = sourceFrame;
                         destination.view.frame = destFrame;
                     }
                     completion:^(BOOL finished) {
                         [source presentViewController:destination animated:NO completion:nil];
                     }];
}

- (void)popViewContorller:(UIViewController *)destination fromViewController:(UIViewController *)source
{
    
}

@end
