//
//  ONERecommendation.m
//  one
//
//  Created by zyy on 14-7-13.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendation.h"
#import "ONELogger.h"

@implementation ONERecommendation

+ (id)instanceWithProperties:(NSDictionary *)properties
{
    return [[self alloc] initWithProperties:properties];
}

- (id)initWithJSONData:(NSData *)jsonData
{
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error == nil) {
        NSInteger code = [result[@"code"] integerValue];
        if (code == 200) {
            NSDictionary *propertiesData = result[@"data"];
            if (propertiesData.count == 0) {
                [ONELogger logTitle:@"empty recommendation data from server..." content:nil];
                return nil;
            } else {
                // 成功
                return [self initWithProperties:propertiesData];
            }
        } else {
            [ONELogger logTitle:@"server error" content:[NSString stringWithFormat:@"response code %ld", (long)code]];
            return nil;
        }
    } else {
        [ONELogger logTitle:@"server error" content:error.localizedDescription];
        return nil;
    }
}

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    
    // must use integerValue here, use (int) to convert will cause bad thing happen
    _city = properties[@"city"];
    _address = properties[@"address"];
    _tel = properties[@"tel"];
    _type = [properties[@"type"] integerValue];
    _title = properties[@"title"];
    _intro = properties[@"intro"];
    _briefDetail = properties[@"briefDetail"];
    _detail = properties[@"detail"];
    _imageUrl = properties[@"imageUrl"];
    _imageLocalLocation = properties[@"imageLocalLocation"];
    if (_imageLocalLocation == nil) {
        _imageLocalLocation = [NSString string];
    }
    _likes = [properties[@"likes"] integerValue];
    _year = [properties[@"year"] integerValue];
    _month = [properties[@"month"] integerValue];
    _day = [properties[@"day"] integerValue];
    _weekday = [properties[@"weekday"] integerValue];
    
    return self;
}

- (NSDictionary *)properties
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjects:
                                @[self.city,
                                  self.address,
                                  self.tel,
                                  @(self.type),
                                  self.title,
                                  self.intro,
                                  self.briefDetail,
                                  self.detail,
                                  self.imageUrl,
                                  self.imageLocalLocation,
                                  @(self.likes),
                                  @(self.year),
                                  @(self.month),
                                  @(self.day),
                                  @(self.weekday),
                                  @(self.collected)]
                                                           forKeys:
                                @[@"city",
                                  @"address",
                                  @"tel",
                                  @"type",
                                  @"title",
                                  @"intro",
                                  @"briefDetail",
                                  @"detail",
                                  @"imageUrl",
                                  @"imageLocalLocation",
                                  @"likes",
                                  @"year",
                                  @"month",
                                  @"day",
                                  @"weekday",
                                  @"collected"]];
    return properties;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[ONERecommendation class]]) {
        ONERecommendation *r = object;
        if ([self.city isEqualToString:r.city] &&
            [self.address isEqualToString:r.address] &&
            [self.tel isEqualToString:r.tel] &&
            self.type == r.type &&
            [self.title isEqualToString:r.title] &&
            [self.intro isEqualToString:r.intro] &&
            [self.briefDetail isEqualToString:r.briefDetail] &&
            [self.detail isEqualToString:r.detail] &&
            [self.imageUrl isEqualToString:r.imageUrl] &&
            self.likes == r.likes &&
            self.year == r.year &&
            self.month == r.month &&
            self.day == r.day) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)hash
{
    return [[self date] hash];
}

- (NSString *)description
{
    return [self date];
}

- (NSString *)date
{
    return [NSString stringWithFormat:@"%@%@%@", @(self.year), @(self.month), @(self.day)];
}

@end
