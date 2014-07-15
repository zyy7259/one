//
//  ONERecommendation.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONERecommendation : NSObject

@property NSString *briefPicUrl;
@property NSUInteger *likes;
@property NSString *title;
@property NSString *description;
@property UIColor *themeColor;
@property NSDateComponents *dateComponents;
@property NSString *city;
@property NSString *type;

- (id)initWithDateComponents:(NSDateComponents *)dateComponents
                       title:(NSString *)title
                 briefPicUrl:(NSString *)briefPicUrl
                 description:(NSString *)description
                  themeColor:(UIColor *)themeColor;
+ (id)recommendationWithDateComponents:(NSDateComponents *)dateComponents
                                 title:(NSString *)title
                           briefPicUrl:(NSString *)briefPicUrl
                           description:(NSString *)description
                            themeColor:(UIColor *)themeColor;

@end
