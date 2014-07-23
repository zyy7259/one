//
//  ONERecommendSimpleViewController.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@protocol ONERecommendationBriefDelegate;

@interface ONERecommendationBriefViewController : UIViewController

@property id<ONERecommendationBriefDelegate> delegate;

@property (nonatomic) ONERecommendation *recommendation;

+ (id)instanceWithDateComponents:(NSDateComponents *)dateComponents;
- (id)initWithDateComponents:(NSDateComponents *)dateComponents;
- (void)shadowIntroView;
- (void)deshadowIntroView;
- (void)startAutoUpdate;
- (void)stopAutoUpdate;
- (void)like;
- (void)dislike;

@end

@protocol ONERecommendationBriefDelegate <NSObject>

- (void)ONERecommendationBriefViewDidLoad:(ONERecommendationBriefViewController *)recommendationBriefViewController;
- (void)ONERecommendationBriefView:(ONERecommendationBriefViewController *)recommendationBriefViewController didUpdateRecommendationLikes:(NSInteger)likes;
- (void)ONERecommendationBriefViewImageTapped;
- (void)ONERecommendationBriefViewBlurViewTapped;
- (void)ONERecommendationBriefViewIntroTapped;

@end