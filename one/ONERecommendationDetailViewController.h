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

@property id<ONERecommendationDetailDelegate> delegate;

- (id)initWithRecommendation:(ONERecommendation *)recommendation;

@end

@protocol ONERecommendationDetailDelegate <NSObject>

- (void)ONERecommendationDetailViewControllerDidFinishDisplay:(ONERecommendationDetailViewController *)recommendationDetailController;

@optional
- (void)ONERecommendationDetailViewControllerDidCollectRecommendation:(ONERecommendation *)recommendation;
- (void)ONERecommendationDetailViewControllerDidDecollectRecommendation:(ONERecommendation *)recommendation;

@end
