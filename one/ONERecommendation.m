//
//  ONERecommendation.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendation.h"

@implementation ONERecommendation

- (id)initWithJSONData:(NSData *)jsonData
{
    NSError *error = [NSError new];
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error == nil) {
        self = [self initWithCity:properties[@"city"]
                             type:properties[@"type"]
                            title:properties[@"title"]
                      description:properties[@"description"]
                         imageUrl:properties[@"imageUrl"]
                            likes:(unsigned long)properties[@"likes"]
                             year:(unsigned long)properties[@"year"]
                            month:(unsigned long)properties[@"month"]
                              day:(unsigned long)properties[@"day"]
                ];
        return self;
    } else {
        return nil;
    }
}

- (id)initWithCity:(NSString *)city type:(NSString *)type title:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrl likes:(NSUInteger)likes year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    self = [super init];
    
    _city = city;
    _type = type;
    _title = title;
    _description = description;
    _imageUrl = imageUrl;
    _likes = likes;
    _year = year;
    _month = month;
    _day = day;
    
    return self;
}

@end
