//
//  ONERecommendSimpleViewController.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONERecommendationBriefViewControllerDelegate;

@interface ONERecommendationBriefViewController : UIViewController

@property (nonatomic) ONERecommendation *recommendation;
@property id<ONERecommendationBriefViewControllerDelegate> delegate;

- (id)initWithRecommendation:(ONERecommendation *)recommendation;
- (void)updateRecommendationImage;
- (void)shadowIntroView;
- (void)deshadowIntroView;

@end

@protocol ONERecommendationBriefViewControllerDelegate <NSObject>

- (void)ONERecommendationBriefViewIntroTapped;
- (void)ONERecommendationBriefViewImageTapped;

@end