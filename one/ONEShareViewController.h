//
//  ONEShareViewController.h
//  one
//
//  Created by zyy on 14-7-21.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONEShareDelegate;

@interface ONEShareViewController : UIViewController

+ (id)sharedShareViewControllerWithDelegate:(UIViewController<ONEShareDelegate> *)delegate;
- (void)shareRecommendation:(ONERecommendation *)recommendation;
- (void)shareApp;
- (void)hideShare;

@end

@protocol ONEShareDelegate <NSObject>

@optional
- (void)ONEShareViewControllerDidFinishDisplay:(ONEShareViewController *)shareViewController;

@end