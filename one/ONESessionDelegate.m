//
//  ONESessionDelegate.m
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONESessionDelegate.h"

@interface ONESessionDelegate ()

@property NSURLSession *defaultSession;
@property NSMutableDictionary *taskDataDictionary;
@property NSMutableDictionary *completionHandlerDictionary;

@end

@implementation ONESessionDelegate

- (id)init
{
    self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    self.taskDataDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Create some configuration objects.
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Configure caching behavior for the default session.
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = myPathList[0];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = @"/CacheDirectory";
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier]
                               stringByAppendingPathComponent:cachePath];
    NSLog(@"Cache path: %@\n", fullCachePath);
    
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
    
    defaultConfigObject.URLCache = myCache;
    defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    // Create a session for each configurations.
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    return self;
}

- (void)addCompletionHandler:(TaskCompletionHandlerType)handler forSession:(NSString *)identifier
{
    
}

- (void)callCompletionHandlerForSession:(NSString *)identifier
{
    
}

- (void)startTaskWithUrl:(NSString *)urlStr completionHandler:(TaskCompletionHandlerType)handler
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithURL:url];
    self.taskDataDictionary[dataTask] = [NSMutableData data];
    self.completionHandlerDictionary[dataTask] = handler;
    [dataTask resume];
}

// fetching data using a custome delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSMutableData *taskData = [self.taskDataDictionary objectForKey:dataTask];
    [taskData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        TaskCompletionHandlerType handler = self.completionHandlerDictionary[task];
        handler(self.taskDataDictionary[task]);
    } else {
        NSLog(@"error %@", error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
}

@end
