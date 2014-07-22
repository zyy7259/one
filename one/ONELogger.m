//
//  ONELogger.m
//  one
//
//  Created by zyy on 14-7-17.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONELogger.h"

@implementation ONELogger

+ (void)logTitle:(NSString *)title content:(NSString *)content
{
    if (content) {
        NSLog(@"\n\nLOG - %@:\n%@\n\n", title, content);
    } else {
        NSLog(@"\n\nLOG - %@\n\n", title);
    }
}

@end
