//
//  ONEDateHelper.h
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEDateUtils : NSObject

+ (ONEDateUtils *)sharedDateHelper;

- (NSDateComponents *)dateComponentsBeforeNDays:(NSUInteger)n;
- (NSString *)briefStringOfMonth:(NSUInteger)month;
- (NSString *)stringOfWeekday:(NSUInteger)weekday;

@end
