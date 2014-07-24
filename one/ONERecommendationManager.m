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
#import "ONEStringUtils.h"

static BOOL debug = YES;

@interface ONERecommendationManager ()

@property ONESessionDelegate *sessionDelegate;
@property NSString *urlBase;
@property NSString *cacheDir;
@property NSString *collectionFileName;

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

+ (ONERecommendationManager *)sharedManager
{
    return sharedSingleton;
}

- (id)init
{
    self = [super init];
    
    self.sessionDelegate = [ONESessionDelegate new];
    
    if (debug) {
        self.urlBase = @"http://localhost:3000";
    } else {
        self.urlBase = @"http://223.252.196.235/OneLife";
    }
    
    self.cacheDir = [[NSHomeDirectory()
                           stringByAppendingPathComponent:@"Library"]
                          stringByAppendingPathComponent:@"Caches"];
    self.collectionFileName = @"collection";
    
    return self;
}

// 读取推荐内容
- (ONERecommendation *)getRecommendationWithDateComponents:(NSDateComponents *)dateComponents dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    ONERecommendation *recommendation = nil;
    
    // 首先从本地读取，如果读取成功，直接返回
    recommendation = [self getRecommendationFromLocalWithDateComponents:dateComponents];
    if (recommendation != nil) {
        return recommendation;
    }
    
    // 如果本地读取不成功，则从服务器读取数据，此次调用会立刻返回；当服务器返回时，调用handler处理返回结果
    recommendation = [self getRecomendationFromServerWithDateComponents:dateComponents dataCompletionHandler:dataHandler imageCompletionHandler:imageHandler];
    
    return recommendation;
}

// 从本地读取推荐内容
- (ONERecommendation *)getRecommendationFromLocalWithDateComponents:(NSDateComponents *)dateComponents
{
    ONERecommendation *recommendation = [self readRecommendationFromFileWithDateComponents:dateComponents];
    return recommendation;
}

// 从服务器下载推荐内容
- (ONERecommendation *)getRecomendationFromServerWithDateComponents:(NSDateComponents *)dateComponents dataCompletionHandler:(RecommendationDataCompletionHandlerType)dataHandler imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    ONERecommendation *recommendation = nil;
    
    NSString *url = [NSString stringWithFormat:@"%@/today?year=%ld&month=%ld&day=%ld", self.urlBase, (long)dateComponents.year, (long)dateComponents.month, (long)dateComponents.day];
    
    [self.sessionDelegate startDataTaskWithUrl:url completionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            // 如果服务器返回成功，用返回的数据来拼装出推荐内容
            ONERecommendation *recommendation = [[ONERecommendation alloc] initWithJSONData:data];
            if (recommendation == nil) {
                dataHandler(nil);
                return;
            }
            
            // 设置推荐内容的日期属性，日期属性被用于把推荐内容保存到本地文件
            recommendation.year = dateComponents.year;
            recommendation.month = dateComponents.month;
            recommendation.day = dateComponents.day;
            recommendation.weekday = dateComponents.weekday;
            
            if (!debug) {
                recommendation.blurredImageUrl = [self.urlBase stringByAppendingPathComponent:recommendation.blurredImageUrl];
                recommendation.imageUrl = [self.urlBase stringByAppendingPathComponent:recommendation.imageUrl];
            }
            
            // 下载推荐内容的图片
            [self downloadRecommendationBlurredImage:recommendation imageCompletionHandler:imageHandler];
            
            // 将推荐内容写入本地文件
            [self writeRecommendationToFile:recommendation];
            
            // 处理推荐内容
            dataHandler(recommendation);
        } else {
            [ONELogger logTitle:@"ERROR - getRecomendationFromServerOfYear" content:[NSString stringWithFormat:@"%@", error]];
            dataHandler(nil);
        }
    }];
    
    return recommendation;
}

// 下载带有灰度的图片
- (void)downloadRecommendationBlurredImage:(ONERecommendation *)recommendation imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    [self downloadRecommendationImage:recommendation imageUrl:recommendation.blurredImageUrl namePostfix:@"blur" imageCompletionHandler:imageHandler];
}

// 下载图片
- (void)downloadRecommendationImage:(ONERecommendation *)recommendation imageUrl:(NSString *)imageUrl namePostfix:(NSString *)namePostfix imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    [self.sessionDelegate startDownloadTaskWithUrl:imageUrl completionHandler:^(NSURL *location, NSError *error) {
        // 如果消息是任务完成，直接返回，不做处理
        if (location == nil && error == nil) {
            return ;
        }
        // 如果有错误
        if (error != nil) {
            [ONELogger logTitle:@"download error" content:error.localizedDescription];
            imageHandler(nil);
            return ;
        }
        
        // 将图片重新命名后放置在本地
        NSError *e = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cacheDirUrl = [NSURL fileURLWithPath:self.cacheDir];
        NSMutableString *fileName = [NSMutableString stringWithFormat:@"%ld%ld%ld", (long)recommendation.year, (long)recommendation.month, (long)recommendation.day];
        if (![ONEStringUtils isEmptyString:namePostfix]) {
            [fileName appendString:namePostfix];
        }
        [fileName appendString:@".jpg"];
        NSURL *targetFileUrl = [cacheDirUrl URLByAppendingPathComponent:fileName];
//        [ONELogger logTitle:@"image new location" content:targetFileUrl.path];
        
        [self clearFileAtUrl:targetFileUrl];
        
        if ([fileManager moveItemAtURL:location toURL:targetFileUrl error:&e]) {
            [ONELogger logTitle:@"cache image success" content:nil];
            // 通知handler新的地址
            imageHandler(targetFileUrl);
        } else {
            [ONELogger logTitle:@"move image failed" content:e.localizedDescription];
            imageHandler(nil);
        }
        
        // 将推荐内容写入本地文件
        [self writeRecommendationToFile:recommendation];
    }];
}

// 清空文件
- (void)clearFileAtUrl:(NSURL *)location
{
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (success) {
        [ONELogger logTitle:@"clear image cache success" content:location.absoluteString];
    } else {
        [ONELogger logTitle:@"clear file cache failed" content:error.localizedDescription];
    }
}

// 将推荐内容写入本地文件
- (void)writeRecommendationToFile:(ONERecommendation *)recommendation
{
    NSString *fileName = [NSString stringWithFormat:@"%ld%ld%ld", (long)recommendation.year, (long)recommendation.month, (long)recommendation.day];
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [recommendation properties];
    BOOL success = [dic writeToFile:filePath atomically:YES];
    NSString *info = [NSString stringWithFormat:@"%@ write recommendation data to file %@", (success ? @"success" : @"fail"), fileName];
    info = info;
//    [ONELogger logTitle:info content:nil];
}

// 从本地文件读取推荐内容
- (ONERecommendation *)readRecommendationFromFileWithDateComponents:(NSDateComponents *)dateComponents
{
    NSString *fileName = [NSString stringWithFormat:@"%ld%ld%ld", (long)dateComponents.year, (long)dateComponents.month, (long)dateComponents.day];
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *info = [NSString stringWithFormat:@"%@ read recommendation data from file %@", (properties != nil ? @"success" : @"fail"), fileName];
    [ONELogger logTitle:info content:nil];
    
    ONERecommendation *recommendation = nil;
    if (properties != nil) {
        recommendation = [[ONERecommendation alloc] initWithProperties:properties];
    }
    
    return recommendation;
}

- (void)getRecommendationLikes:(ONERecommendation *)recommendation likesHandler:(RecommendationLikesCompletionHandlerType)likesHandler
{
    NSString *url = [NSString stringWithFormat:@"%@/getlike?year=%ld&month=%ld&day=%ld", self.urlBase, (long)recommendation.year, (long)recommendation.month, (long)recommendation.day];
    [self.sessionDelegate startDataTaskWithUrl:url completionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSError *e = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
            if (e == nil) {
                NSInteger code = [result[@"code"] integerValue];
                if (code == 200) {
                    NSDictionary *likeData = result[@"data"];
                    if (likeData.count == 0) {
                        // empty
                    } else {
                        // success
                        NSInteger likes = [likeData[@"likes"] integerValue];
                        recommendation.likes = likes;
                        [self writeRecommendationToFile:recommendation];
                        likesHandler(likes);
                        return;
                    }
                }
            }
        }
        likesHandler(-1);
    }];
}

- (void)likeRecommendation:(ONERecommendation *)recommendation
{
    [self updateRecommendationLike:recommendation action:1];
}

- (void)dislikeRecommendation:(ONERecommendation *)recommendation
{
    [self updateRecommendationLike:recommendation action:-1];
}

- (void)updateRecommendationLike:(ONERecommendation *)recommendation action:(NSInteger)action
{
    NSString *url = [NSString stringWithFormat:@"%@/like?year=%ld&month=%ld&day=%ld&action=%ld", self.urlBase, (long)recommendation.year, (long)recommendation.month, (long)recommendation.day, (long)action];
    [self.sessionDelegate startDataTaskWithUrl:url completionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSError *e = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
            if (e == nil) {
                NSInteger code = [result[@"code"] integerValue];
                if (code == 200) {
                    recommendation.likes += action;
                    [self writeRecommendationToFile:recommendation];
                    return;
                }
            }
        }
    }];
}

// 将收藏列表写入本地文件
- (void)writeRecommendationCollectionToFile:(NSArray *)recommendationArray
{
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:recommendationArray.count];
    for (ONERecommendation *recommendation in recommendationArray) {
        [propertiesArray addObject:[recommendation properties]];
    }
    
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:self.collectionFileName];
    BOOL success = [propertiesArray writeToFile:filePath atomically:YES];
    NSString *info = [NSString stringWithFormat:@"%@ write collection to file %@", (success ? @"success" : @"fail"), self.collectionFileName];
    [ONELogger logTitle:info content:nil];
}

// 从本地文件读取收藏列表
- (NSMutableArray *)readRecommendationCollectionFromFile
{
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:self.collectionFileName];
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    NSString *info = [NSString stringWithFormat:@"%@ read recommendation collection from file %@", (propertiesArray != nil ? @"success" : @"fail"), filePath];
    [ONELogger logTitle:info content:nil];
    
    NSMutableArray *recommendationArray = [NSMutableArray arrayWithCapacity:propertiesArray.count];
    for (NSDictionary *properties in propertiesArray) {
        ONERecommendation *recommendation = [[ONERecommendation alloc] initWithProperties:properties];
        [recommendationArray addObject:recommendation];
    }
    return recommendationArray;
}

@end
