//
//  ONERecommendation.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendation.h"

@implementation ONERecommendation

- (id)initWithDateComponents:(NSDateComponents *)dateComponents title:(NSString *)title briefPicUrl:(NSString *)briefPicUrl description:(NSString *)description
{
    self = [super init];
    _dateComponents = dateComponents;
    _title = title;
    _briefPicUrl = briefPicUrl;
    _description = description;
    return self;
}

+ (id)recommendationWithDateComponents:(NSDateComponents *)dateComponents title:(NSString *)title briefPicUrl:(NSString *)briefPicUrl description:(NSString *)description
{
    return [[self alloc] initWithDateComponents:dateComponents title:title briefPicUrl:briefPicUrl description:description];
}

@end
