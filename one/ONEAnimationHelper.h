//
//  ONEAnimationHelper.h
//  one
//
//  Created by zyy on 14-7-20.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEAnimationHelper : NSObject

typedef void (^animationCompletionHandlerType)();

+ (ONEAnimationHelper *)sharedAnimationHelper;

- (void)pushViewController:(UIViewController *)destination toViewController:(UIViewController *)source;
- (void)popViewContorller:(UIViewController *)destination fromViewController:(UIViewController *)source;
- (void)moveViewController:(UIViewController *)vc toFrame:(CGRect)destinationFrame completion:(animationCompletionHandlerType)handler;

@end
