//
//  ONERecommendationManager.h
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ONERecommendation.h"

typedef void (^RecommendationDataCompletionHandlerType)(ONERecommendation *r);
typedef void (^RecommendationImageCompletionHandlerType)(NSURL *location);
typedef void (^RecommendationLikesCompletionHandlerType)(NSInteger likes);

@interface ONERecommendationManager : NSObject

+ (ONERecommendationManager *)sharedManager;

- (ONERecommendation *)getRecommendationWithDateComponents:(NSDateComponents *)dateComponents
                                     dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler
                                    imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler;
- (void)downloadRecommendationBlurredImage:(ONERecommendation *)recommendation imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler;
- (void)downloadRecommendationImage:(ONERecommendation *)recommendation imageUrl:(NSString *)imageUrl namePostfix:(NSString *)namePostfix imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler;

- (void)getRecommendationLikes:(ONERecommendation *)recommendation likesHandler:(RecommendationLikesCompletionHandlerType)likesHandler;
- (void)likeRecommendation:(ONERecommendation *)recommendation;
- (void)dislikeRecommendation:(ONERecommendation *)recommendation;

- (void)writeRecommendationCollectionToFile:(NSArray *)recommendationArray;

- (NSMutableArray *)readRecommendationCollectionFromFile;

@end
