//
//  ONEDateHelper.m
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEDateHelper.h"

@interface ONEDateHelper ()

@property NSCalendar *gregorian;
@property NSCalendarUnit calendarUnits;
@property NSDateComponents *todayComponents;
@property NSArray *monthBriefStrings;
@property NSArray *weekdayStrings;

@end

@implementation ONEDateHelper

static ONEDateHelper *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSingleton = [ONEDateHelper new];
    }
}

+ (ONEDateHelper *)defaultDateHelper
{
    return sharedSingleton;
}

- (id)init
{
    self = [super init];
    [self initDateComponents];
    return self;
}

- (void)initDateComponents
{
    // Date components of today
    NSDate *today = [NSDate date];
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    _calendarUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    _todayComponents = [self.gregorian components:self.calendarUnits fromDate:today];
    _monthBriefStrings = [NSArray arrayWithObjects:
                          @"",
                          @"Jan",
                          @"Feb",
                          @"Mar",
                          @"Apr",
                          @"May",
                          @"Jun",
                          @"Jul",
                          @"Aug",
                          @"Sept",
                          @"Oct",
                          @"Nov",
                          @"Dec", nil];
    _weekdayStrings = [NSArray arrayWithObjects:
                       @"",
                       @"Sunday",
                       @"Monday",
                       @"Tuesday",
                       @"Wednesday",
                       @"Thursday",
                       @"Friday",
                       @"Saturday",
                       nil];
}

- (NSDateComponents *)dateComponentsBeforeNDays:(NSUInteger)n
{
    NSDateComponents *offsetComponents = [NSDateComponents new];
    offsetComponents.day = -n;
    NSDate *targetDate = [self.gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    return [self.gregorian components:self.calendarUnits fromDate:targetDate];
}

- (NSString *)briefStringOfMonth:(NSUInteger)month
{
    return self.monthBriefStrings[month];
}

- (NSString *)stringOfWeekday:(NSUInteger)weekday
{
    return self.weekdayStrings[weekday];
}

@end
