//
//  ONERecommendationManager.h
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONERecommendation.h"

typedef void (^RecommendationCompletionHandlerType)(ONERecommendation *r);

@interface ONERecommendationManager : NSObject

- (ONERecommendation *)getRecommendationOfYear:(NSUInteger)year
                                         month:(NSUInteger)month
                                           day:(NSUInteger)day
                             completionHandler:(RecommendationCompletionHandlerType)handler;

+ (ONERecommendationManager *)onlyManager;

@end
