//
//  ONERecommendationImageViewController.h
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONERecommendationImageDelegate;

@interface ONERecommendationImageViewController : UIViewController

@property id<ONERecommendationImageDelegate> delegate;

+ (id)instanceWithRecommendation:(ONERecommendation *)recommendation;
- (id)initWithRecommendation:(ONERecommendation *)recommendation;

@end

@protocol ONERecommendationImageDelegate <NSObject>

- (void)ONERecommendationImageViewControllerDidFinishDisplay:(ONERecommendationImageViewController *)recommendationImageController;

@end