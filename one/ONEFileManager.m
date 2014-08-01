//
//  ONEFileManager.m
//  ONELife
//
//  Created by zyy on 14-8-1.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEFileManager.h"

@implementation ONEFileManager

+ (NSDictionary *)JSONObjectWithContentsOfFile:(NSString *)name
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
}

@end
