//
//  ONESessionDelegate.m
//  one
//
//  Created by zyy on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONESessionDelegate.h"
#import "ONELogger.h"

@interface ONESessionDelegate ()

@property NSURLSession *defaultSession;
@property NSMutableDictionary *dataTaskDataDictionary;
@property NSMutableDictionary *completionHandlerDictionary;

@end

@implementation ONESessionDelegate

- (id)init
{
    self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    self.dataTaskDataDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Create some configuration objects.
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Configure caching behavior for the default session.
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = myPathList[0];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = @"/CacheDirectory";
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier]
                               stringByAppendingPathComponent:cachePath];
    [ONELogger logTitle:@"Cache path" content:fullCachePath];
    
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
    
    defaultConfigObject.URLCache = myCache;
    defaultConfigObject.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    // Create a session for each configurations.
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    return self;
}

- (void)addCompletionHandler:(DataTaskCompletionHandlerType)handler forSession:(NSString *)identifier
{
    
}

- (void)callCompletionHandlerForSession:(NSString *)identifier
{
    
}

// start a data task of the url.
// create a data object for the task, which will be used to store the data received.
// store the handler, which will be called when data task finished.
- (void)startDataTaskWithUrl:(NSString *)urlStr completionHandler:(DataTaskCompletionHandlerType)handler
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithURL:url];
    self.dataTaskDataDictionary[dataTask] = [NSMutableData data];
    self.completionHandlerDictionary[dataTask] = handler;
    [dataTask resume];
}

// start a download task of the url.
// store the handler, which will be called when download finished or failed.
- (void)startDownloadTaskWithUrl:(NSString *)urlStr completionHandler:(DownloadTaskCompletionHandlerType)handler
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDownloadTask *downloadTask = [self.defaultSession downloadTaskWithURL:url];
    self.completionHandlerDictionary[downloadTask] = handler;
    [downloadTask resume];
}

// when receiving data, store it
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSMutableData *taskData = [self.dataTaskDataDictionary objectForKey:dataTask];
    [taskData appendData:data];
}

// when finish, call the previously stored handler
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
        DataTaskCompletionHandlerType handler = self.completionHandlerDictionary[task];
        // pass the error anyway, let the handler to handle the error
        handler(self.dataTaskDataDictionary[task], error);
    } else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        DownloadTaskCompletionHandlerType handler = self.completionHandlerDictionary[task];
        handler(nil, error);
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
    [ONELogger logTitle:@"finish downloading to URL" content:location.path];
    DownloadTaskCompletionHandlerType handler = self.completionHandlerDictionary[downloadTask];
    handler(location, nil);
}

@end
