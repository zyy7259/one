//
//  ONEShareViewController.h
//  one
//
//  Created by zyy on 14-7-21.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONERecommendationShareDelegate;

@interface ONERecommendationShareViewController : UIViewController

@property (nonatomic) ONERecommendation *recommendation;
@property id<ONERecommendationShareDelegate> delegate;

- (id)initWithRecommendation:(ONERecommendation *)recommendation;

@end

@protocol ONERecommendationShareDelegate <NSObject>

- (void)ONERecommendationShareViewControllerDidFinishDisplay:(ONERecommendationShareViewController *)recommendationShareViewController;

@end