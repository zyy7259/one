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
@property NSString *address;
@property NSString *tel;
@property NSInteger type;
@property NSString *title;
@property NSString *intro;
@property NSString *briefDetail;
@property NSString *detail;
@property NSString *blurredImageUrl;
@property NSString *blurredImageLocalLocation;
@property NSString *imageUrl;
@property NSString *imageLocalLocation;
@property NSInteger likes;
@property NSInteger year;
@property NSInteger month;
@property NSInteger day;
@property NSInteger weekday;

@property (nonatomic) BOOL collected;

- (id)initWithJSONData:(NSData *)jsonData;
- (id)initWithProperties:(NSDictionary *)properties;

- (NSDictionary *)properties;
- (NSString *)date;

@end
