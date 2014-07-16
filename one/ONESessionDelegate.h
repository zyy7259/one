//
//  ONESessionDelegate.h
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TaskCompletionHandlerType)(NSData *data, NSError *error);

@interface ONESessionDelegate : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

- (void)addCompletionHandler:(TaskCompletionHandlerType)handler forSession:(NSString *)identifier;

- (void)startTaskWithUrl:(NSString *)urlStr completionHandler:(TaskCompletionHandlerType)handler;

@end
