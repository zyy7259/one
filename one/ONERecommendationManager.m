//
//  ONERecommendationManager.m
//  one
//
//  Created by : on 14-7-16.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONERecommendationManager.h"
#import "ONESessionDelegate.h"
#import "ONELogger.h"

@interface ONERecommendationManager ()

@property ONESessionDelegate *sessionDelegate;
@property NSString *urlBase;

@end

@implementation ONERecommendationManager

static ONERecommendationManager *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSingleton = [ONERecommendationManager new];
    }
}

+ (ONERecommendationManager *)defaultManager
{
    return sharedSingleton;
}

- (id)init
{
    self = [super init];
    
    self.sessionDelegate = [ONESessionDelegate new];
    self.urlBase = @"http://localhost:3000/";
    
    return self;
}

- (ONERecommendation *)getRecommendationOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    ONERecommendation *recommendation = nil;
    
    // first find the recommendation from local
    recommendation = [self getRecommendationFromLocalOfYear:year month:month day:day];
    if (recommendation != nil) {
        return recommendation;
    }
    
    // then find the recommendation from server, this call will return immediately
    // when the server response, will call the handler to process the result
    recommendation = [self getRecomendationFromServerOfYear:year month:month day:day dataCompletionHandler:dataHandler imageCompletionHandler:imageHandler];
    
    // if local search failed, fake it
    recommendation = [self fakeRecommendationOfYear:year month:month day:day];
    
    return recommendation;
}

- (ONERecommendation *)getRecommendationFromLocalOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = nil;
    return recommendation;
}

- (ONERecommendation *)getRecomendationFromServerOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    ONERecommendation *recommendation = nil;
    
    NSString *url = [NSString stringWithFormat:@"%@recommendation?year=%lu&month=%lu&day=%lu", self.urlBase, (unsigned long)year, (unsigned long)month, (unsigned long)day];
    
    [self.sessionDelegate startDataTaskWithUrl:url completionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            // if success, use the data to init the recommendation and set the date
            ONERecommendation *recommendation = [[ONERecommendation alloc] initWithJSONData:data];
            recommendation.year = year;
            recommendation.month = month;
            recommendation.day = day;
            // TODO in production, splice the imageUrl.
//            recommendation.imageUrl = [self.urlBase stringByAppendingString:recommendation.imageUrl];
            // download the recommendation's image
            [self downloadImageWithUrl:recommendation.imageUrl year:year month:month day:day imageCompletionHandler:imageHandler];
            // pass the recommendation to the handler
            dataHandler(recommendation);
        } else {
            NSLog(@"ERROR - getRecomendationFromServerOfYear: %@", error);
        }
    }];
    
    return recommendation;
}

- (void)downloadImageWithUrl:(NSString *)url year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    [self.sessionDelegate startDownloadTaskWithUrl:url completionHandler:^(NSURL *location, NSError *error) {
        // 如果消息是任务完成，直接返回，不做处理
        if (location == nil && error == nil) {
            return ;
        }
        // 如果有错误
        if (error != nil) {
            [ONELogger logTitle:@"download error" content:error.localizedDescription];
            return ;
        }
        
        // 将图片重新命名后放置在本地
        NSError *e = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cacheDir = [[NSHomeDirectory()
                               stringByAppendingPathComponent:@"Library"]
                              stringByAppendingPathComponent:@"Caches"];
        NSURL *cacheDirUrl = [NSURL fileURLWithPath:cacheDir];
        NSURL *targetFileUrl = [cacheDirUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu%lu%lu.jpg", (unsigned long)year, (unsigned long)month, (unsigned long)day]];
        [ONELogger logTitle:@"new location" content:targetFileUrl.path];
        
        [self clearFileAtUrl:targetFileUrl];
        
        if ([fileManager moveItemAtURL:location toURL:targetFileUrl error:&e]) {
            // store some reference to the new URL
            [ONELogger logTitle:@"cache image success" content:nil];
            imageHandler(targetFileUrl);
        } else {
            [ONELogger logTitle:@"move file failed" content:e.localizedDescription];
            imageHandler(nil);
        }
    }];
}

- (void)clearFileAtUrl:(NSURL *)location
{
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (success) {
        [ONELogger logTitle:@"clear file success" content:location.absoluteString];
    } else {
        [ONELogger logTitle:@"clear file failed" content:error.localizedDescription];
    }
}

- (void)clearLocation:(NSURL *)location atDir:(NSURL *)dir
{
    NSArray *pathComponnets = location.pathComponents;
    NSLog(@"%@", pathComponnets);
    NSString *lastPathComponent = location.lastPathComponent;
    NSLog(@"%@", lastPathComponent);
    NSString *pathExtension = location.pathExtension;
    NSLog(@"%@", pathExtension);
    
    NSURL *filePath = [dir URLByAppendingPathComponent:location.lastPathComponent];
    NSLog(@"\n\nremove file%@", filePath);
    if ([filePath isFileURL]) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtURL:filePath error:&error];
        if (!success || error) {
            NSLog(@"\n\nremove failed.");
        } else {
            NSLog(@"\n\nremove success.");
        }
    }
}

- (void)clearDir:(NSString *)dir
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:dir error:&error]) {
        NSString *filePath = [dir stringByAppendingPathComponent:file];
        if ([[NSURL URLWithString:filePath] isFileURL]) {
            NSLog(@"\n\nbegin delete file:%@", filePath);
            BOOL success = [fm removeItemAtPath:filePath error:&error];
            if (!success || error) {
                // failed.
                NSLog(@"\n\ndelete file failed, error\n%@\n", error);
            } else {
                NSLog(@"\n\ndelete file success");
            }
        }
    }
}

- (ONERecommendation *)fakeRecommendationOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = [[ONERecommendation alloc]
                                         initWithCity:@"杭州-fake"
                                         type:0
                                         title:@"title-fake"
                                         description:@"description-fake"
                                         imageUrl:@"bg.jpg"
                                         likes:0
                                         year:year
                                         month:month
                                         day:day];
    return recommendation;
}

@end
