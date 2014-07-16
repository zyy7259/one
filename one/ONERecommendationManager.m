//
//  ONERecommendationManager.m
//  one
//
//  Created by : on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationManager.h"
#import "ONESessionDelegate.h"

@interface ONERecommendationManager ()

@property ONESessionDelegate *sessionDelegate;

@end

@implementation ONERecommendationManager

- (ONERecommendation *)getRecommendationOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{

    ONERecommendation *recommendation = nil;
    
    // first find the recommendation from local
    recommendation = [self getRecommendationFromLocalOfYear:year month:month day:day];
    if (recommendation != nil) {
        return recommendation;
    }
    
    // then find the recommendation from server
    recommendation = [self getRecomendationFromServerOfYear:year month:month day:day];
    if (recommendation != nil) {
        return recommendation;
    }
    
    // if both failed, fake it
    recommendation = [self fakeRecommendationOfYear:year month:month day:day];
    
    return recommendation;
}

- (ONERecommendation *)getRecommendationFromLocalOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = nil;
    return recommendation;
}

- (ONERecommendation *)getRecomendationFromServerOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = nil;
    
    if (self.sessionDelegate == nil) {
        self.sessionDelegate = [ONESessionDelegate new];
    }
    [self.sessionDelegate startTaskWithUrl:@"http://localhost:3000/" completionHandler:^(NSData *data) {
        NSLog(@"DATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    return recommendation;
}

- (ONERecommendation *)fakeRecommendationOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = [[ONERecommendation alloc]
                                         initWithCity:@"杭州"
                                         type:@"one"
                                         title:@"title"
                                         description:@"description"
                                         imageUrl:@"404"
                                         likes:0
                                         year:year
                                         month:month
                                         day:day];
    return recommendation;
}

@end
