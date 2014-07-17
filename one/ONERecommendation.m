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
                ];
        return self;
    } else {
        NSLog(@"error:\n%@", error);
        return nil;
    }
}

- (id)initWithCity:(NSString *)city address:(NSString *)address type:(NSUInteger)type title:(NSString *)title intro:(NSString *)intro briefDetail:(NSString *)briefDetail detail:(NSString *)detail imageUrl:(NSString *)imageUrl likes:(NSUInteger)likes year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
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
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"city: %@\t\ttype: %@\t\ttitle: %@\nintro: %@\nimageUrl: %@\nlikes: %@\t\t\tyear: %@\t\t\tmonth: %@\t\t\tday: %@\n", self.city, @(self.type), self.title, self.intro, self.imageUrl, @(self.likes), @(self.year), @(self.month), @(self.day)];
}

@end
