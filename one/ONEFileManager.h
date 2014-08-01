//
//  ONEFileManager.h
//  ONELife
//
//  Created by zyy on 14-8-1.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEFileManager : NSObject

+ (NSDictionary *)JSONObjectWithContentsOfFile:(NSString *)name;

@end
