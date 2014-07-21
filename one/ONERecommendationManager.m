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
@property NSString *cacheDir;
@property NSString *collectionFileName;
@property BOOL debug;

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
    
    self.debug = YES;
    if (self.debug) {
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
    
    NSString *url = [NSString stringWithFormat:@"%@/today?year=%d&month=%d&day=%d", self.urlBase, dateComponents.year, dateComponents.month, dateComponents.day];
    
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
            
            if (!self.debug) {
                recommendation.blurredImageUrl = [self.urlBase stringByAppendingString:recommendation.blurredImageUrl];
            }
            
            // 下载推荐内容的图片
            [self downloadRecommendationImage:recommendation imageCompletionHandler:imageHandler];
            
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

// 下载图片
- (void)downloadRecommendationImage:(ONERecommendation *)recommendation imageCompletionHandler:(RecommendationImageCompletionHandlerType)imageHandler
{
    [self.sessionDelegate startDownloadTaskWithUrl:recommendation.blurredImageUrl completionHandler:^(NSURL *location, NSError *error) {
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
        NSURL *cacheDirUrl = [NSURL fileURLWithPath:self.cacheDir];
        NSURL *targetFileUrl = [cacheDirUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%d%d%d.jpg", recommendation.year, recommendation.month, recommendation.day]];
        [ONELogger logTitle:@"image new location" content:targetFileUrl.path];
        
        [self clearFileAtUrl:targetFileUrl];
        
        if ([fileManager moveItemAtURL:location toURL:targetFileUrl error:&e]) {
            [ONELogger logTitle:@"cache image success" content:nil];
            // 记录新的图片地址后，通知handler
            recommendation.blurredImageUrl = targetFileUrl.path;
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
    NSString *fileName = [NSString stringWithFormat:@"%d%d%d", recommendation.year, recommendation.month, recommendation.day];
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [recommendation properties];
    BOOL success = [dic writeToFile:filePath atomically:YES];
    NSString *info = [NSString stringWithFormat:@"%@ write recommendation data to file %@", (success ? @"success" : @"fail"), fileName];
    [ONELogger logTitle:info content:nil];
}

// 从本地文件读取推荐内容
- (ONERecommendation *)readRecommendationFromFileWithDateComponents:(NSDateComponents *)dateComponents
{
    NSString *fileName = [NSString stringWithFormat:@"%d%d%d", dateComponents.year, dateComponents.month, dateComponents.day];
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
