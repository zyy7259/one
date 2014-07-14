//
//  ONERecommendation.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONERecommendation : NSObject

@property NSDateComponents *dateComponents;
@property NSString *title;
@property NSString *briefPicUrl;
@property NSString *description;

- (id)initWithDateComponents:(NSDateComponents *)dateComponents title:(NSString *)title briefPicUrl:(NSString *)briefPicUrl description:(NSString *)description;
+ (id)recommendationWithDateComponents:(NSDateComponents *)dateComponents title:(NSString *)title briefPicUrl:(NSString *)briefPicUrl description:(NSString *)description;

@end
