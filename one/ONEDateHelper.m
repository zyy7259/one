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

@end

@implementation ONEDateHelper

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)initDateComponents
{
    // Date components of today
    NSDate *today = [NSDate date];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.calendarUnits = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    self.todayComponents = [self.gregorian components:self.calendarUnits fromDate:today];
}

- (NSDateComponents *)dateComponentsBeforeNDays:(NSUInteger)n
{
    NSDateComponents *offsetComponents = [NSDateComponents new];
    offsetComponents.day = -n;
    NSDate *targetDate = [self.gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    return [self.gregorian components:self.calendarUnits fromDate:targetDate];
}

@end
