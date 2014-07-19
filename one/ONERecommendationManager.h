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

@interface ONERecommendationManager : NSObject

+ (ONERecommendationManager *)sharedManager;

- (ONERecommendation *)getRecommendationWithDateComponents:(NSDateComponents *)dateComponents
                                     dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler
                                    imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler;

- (void)writeRecommendationCollectionToFile:(NSArray *)recommendationArray;

- (NSMutableArray *)readRecommendationCollectionFromFile;

@end
