//
//  ONESessionDelegate.h
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataTaskCompletionHandlerType)(NSData *data, NSError *error);
typedef void (^DownloadTaskCompletionHandlerType)(NSURL *location, NSError *error);

@interface ONESessionDelegate : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

- (void)addCompletionHandler:(DataTaskCompletionHandlerType)handler forSession:(NSString *)identifier;

- (void)startDataTaskWithUrl:(NSString *)urlStr completionHandler:(DataTaskCompletionHandlerType)handler;

- (void)startDownloadTaskWithUrl:(NSString *)urlStr completionHandler:(DownloadTaskCompletionHandlerType)handler;

@end
