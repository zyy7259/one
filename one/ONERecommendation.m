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
//    NSLog(@"DATA:\n%@\nEND DATA\n", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSError *error = nil;
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    // must use intValue here, use (int) to convert will cause bad thing happen
    if (error == nil) {
        return [self initWithProperties:properties];
    } else {
        NSLog(@"error:\n%@", error);
        return nil;
    }
}

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [self initWithCity:properties[@"city"]
                      address:properties[@"address"]
                         type:[properties[@"type"] intValue]
                        title:properties[@"title"]
                        intro:properties[@"intro"]
                  briefDetail:properties[@"briefDetail"]
                       detail:properties[@"detail"]
                     imageUrl:properties[@"imageUrl"]
                        likes:[properties[@"likes"] intValue]
                         year:[properties[@"year"] intValue]
                        month:[properties[@"month"] intValue]
                          day:[properties[@"day"] intValue]
                      weekday:[properties[@"weekday"] intValue]
            ];
    return self;
}

- (id)initWithCity:(NSString *)city address:(NSString *)address type:(NSUInteger)type title:(NSString *)title intro:(NSString *)intro briefDetail:(NSString *)briefDetail detail:(NSString *)detail imageUrl:(NSString *)imageUrl likes:(NSUInteger)likes year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day weekday:(NSUInteger)weekday
{
    self = [super init];
    
    _city = city;
    _address = address;
    _type = type;
    _title = title;
    _intro = intro;
    _briefDetail = briefDetail;
    _detail = detail;
    _imageUrl = imageUrl;
    _likes = likes;
    _year = year;
    _month = month;
    _day = day;
    _weekday = weekday;
    
    return self;
}

- (NSDictionary *)properties
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjects: @[self.city,
                                                                      self.address,
                                                                      @(self.type),
                                                                      self.title,
                                                                      self.intro,
                                                                      self.briefDetail,
                                                                      self.detail,
                                                                      self.imageUrl,
                                                                      @(self.likes),
                                                                      @(self.year),
                                                                      @(self.month),
                                                                      @(self.day),
                                                                      @(self.weekday),
                                                                      @(self.collected)]
                                                           forKeys:@[@"city",
                                                                     @"address",
                                                                     @"type",
                                                                     @"title",
                                                                     @"intro",
                                                                     @"briefDetail",
                                                                     @"detail",
                                                                     @"imageUrl",
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

- (void)updateCollected:(BOOL)collected
{
    self.collected = collected;
    if (self.collected) {
        [self.delegate ONERecommendationDidCollect:self];
    } else {
        [self.delegate ONERecommendationDidDecollect:self];
    }
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%@%@%@", @(self.year), @(self.month), @(self.day)] hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"city: %@\t\ttype: %@\t\ttitle: %@\nintro: %@\nimageUrl: %@\nlikes: %@\t\t\tyear: %@\t\t\tmonth: %@\t\t\tday: %@\n", self.city, @(self.type), self.title, self.intro, self.imageUrl, @(self.likes), @(self.year), @(self.month), @(self.day)];
}

- (NSString *)date
{
    return [NSString stringWithFormat:@"%@%@%@", @(self.year), @(self.month), @(self.day)];
}

@end
