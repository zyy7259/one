//
//  ONERecommendDetailViewController.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONERecommendationDetailDelegate;

@interface ONERecommendationDetailViewController : UIViewController

- (id)initWithRecommendation:(ONERecommendation *)recommendation;

@property id<ONERecommendationDetailDelegate> delegate;

@end

@protocol ONERecommendationDetailDelegate <NSObject>

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController;

@optional
- (void)ONERecommendationDetailViewControllerDidCollectRecommendation:(ONERecommendation *)recommendation;
- (void)ONERecommendationDetailViewControllerDidDecollectRecommendation:(ONERecommendation *)recommendation;

@end
