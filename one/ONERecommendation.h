//
//  ONERecommendation.h
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONERecommendation : NSObject

@property NSString *city;
@property NSUInteger type;
@property NSString *title;
@property NSString *intro;
@property NSString *briefDetail;
@property NSString *detail;
@property NSString *imageUrl;
@property NSUInteger likes;
@property NSUInteger year;
@property NSUInteger month;
@property NSUInteger day;

- (id)initWithJSONData:(NSData *)jsonData;

- (id)initWithCity:(NSString *)city
              type:(NSUInteger)type
             title:(NSString *)title
       intro:(NSString *)intro
          imageUrl:(NSString *)imageUrl
             likes:(NSUInteger)likes
              year:(NSUInteger)year
             month:(NSUInteger)month
               day:(NSUInteger)day;

@end
