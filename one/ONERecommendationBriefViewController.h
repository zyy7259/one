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

@property id<ONERecommendationBriefViewControllerDelegate> delegate;

@property (nonatomic) ONERecommendation *recommendation;

+ (id)instanceWithDateComponents:(NSDateComponents *)dateComponents;
- (id)initWithDateComponents:(NSDateComponents *)dateComponents;
- (void)shadowIntroView;
- (void)deshadowIntroView;

@end

@protocol ONERecommendationBriefViewControllerDelegate <NSObject>

- (void)ONERecommendationBriefViewIntroTapped;
- (void)ONERecommendationBriefViewImageTapped;

@end