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
    
    self.cacheDir = [[NSHomeDirectory()
                           stringByAppendingPathComponent:@"Library"]
                          stringByAppendingPathComponent:@"Caches"];
    
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
    
    return recommendation;
}

- (ONERecommendation *)getRecommendationFromLocalOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ONERecommendation *recommendation = [self readRecommendationFromFileOfYear:year month:month day:day];
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
            
            // set the date of the recommendation, which will use to save the recommendation to local file
            recommendation.year = year;
            recommendation.month = month;
            recommendation.day = day;
            
            // TODO in production, splice the imageUrl.
//            recommendation.imageUrl = [self.urlBase stringByAppendingString:recommendation.imageUrl];

            // save recommendation to local file
            [self writeRecommendationToFile:recommendation];
            
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
        NSURL *cacheDirUrl = [NSURL fileURLWithPath:self.cacheDir];
        NSURL *targetFileUrl = [cacheDirUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu%lu%lu.jpg", (unsigned long)year, (unsigned long)month, (unsigned long)day]];
        [ONELogger logTitle:@"image new location" content:targetFileUrl.path];
        
        [self clearFileAtUrl:targetFileUrl];
        
        if ([fileManager moveItemAtURL:location toURL:targetFileUrl error:&e]) {
            // store some reference to the new URL
            [ONELogger logTitle:@"cache image success" content:nil];
            imageHandler(targetFileUrl);
        } else {
            [ONELogger logTitle:@"move image failed" content:e.localizedDescription];
            imageHandler(nil);
        }
    }];
}

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

- (void)writeRecommendationToFile:(ONERecommendation *)recommendation
{
    NSString *fileName = [NSString stringWithFormat:@"%lu%lu%lu", (unsigned long)recommendation.year, (unsigned long)recommendation.month, (unsigned long)recommendation.day];
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects: @[recommendation.city,
                                                               recommendation.address,
                                                               @(recommendation.type),
                                                               recommendation.title,
                                                               recommendation.intro,
                                                               recommendation.briefDetail,
                                                               recommendation.detail,
                                                               recommendation.imageUrl,
                                                               @(recommendation.likes),
                                                               @(recommendation.year),
                                                               @(recommendation.month),
                                                               @(recommendation.day)]
                                                    forKeys:@[@"city",
                                                              @"address",
                                                              @"type",
                                                              @"title",
                                                              @"intro",
                                                              @"briefDetail",
                                                              @"detail",
                                                              @"imageUrl",
                                                              @"likes",
                                                              @"year",
                                                              @"month",
                                                              @"day"]];
    BOOL success = [dic writeToFile:filePath atomically:YES];
    NSString *info = [NSString stringWithFormat:@"%@ write recommendation data to file %@", (success ? @"success" : @"fail"), fileName];
    [ONELogger logTitle:info content:nil];
}

- (ONERecommendation *)readRecommendationFromFileOfYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    NSString *fileName = [NSString stringWithFormat:@"%lu%lu%lu", (unsigned long)year, (unsigned long)month, (unsigned long)day];
    NSString *filePath = [self.cacheDir stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *info = [NSString stringWithFormat:@"%@ read recommendation data from file %@", (dic != nil ? @"success" : @"fail"), filePath];
    [ONELogger logTitle:info content:nil];
    
    ONERecommendation *recommendation = nil;
    if (dic != nil) {
        recommendation = [[ONERecommendation alloc]
                          initWithCity:dic[@"city"]
                          address:dic[@"address"]
                          type:[dic[@"type"] intValue]
                          title:dic[@"title"]
                          intro:dic[@"intro"]
                          briefDetail:dic[@"briefDetail"]
                          detail:dic[@"detail"]
                          imageUrl:dic[@"imageUrl"]
                          likes:[dic[@"likes"] intValue]
                          year:[dic[@"year"] intValue]
                          month:[dic[@"month"] intValue]
                          day:[dic[@"day"] intValue]];
    }
    
    return recommendation;
    // TODO 若返回nil，则强制从服务器取数据
//    return nil;
}

@end
