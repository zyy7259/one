//
//  ONERecommendSimpleViewController.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONERecommendation.h"

@interface ONERecommendationBriefViewController : UIViewController

@property (nonatomic) ONERecommendation *recommendation;

- (id)initWithRecommendation:(ONERecommendation *)recommendation;

- (void)updateRecommendationImage;

@end
