//
//  ONEResourceManager.m
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEResourceManager.h"

@interface ONEResourceManager ()

@property NSArray *briefTypeImages;
@property NSArray *detailTypeImages;
@property NSArray *collectTypeImages;

@end

@implementation ONEResourceManager

static ONEResourceManager *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedSingleton = [ONEResourceManager new];
    }
}

+ (ONEResourceManager *)sharedManager
{
    return sharedSingleton;
}

- (id)init
{
    self = [super init];
    
    [self initImages];
    
    return self;
}

- (void)initImages
{
    self.onelifeImage = [UIImage imageNamed:@"onelife"];
    self.onelifeArticleTmpImage = [UIImage imageNamed:@"onelifeArticleTmp"];
    [self initButtonImages];
    [self initTypeImages];
}

- (void)initButtonImages
{
    self.returnImage = [UIImage imageNamed:@"return"];
    self.returnSelectedImage = [UIImage imageNamed:@"returnSelected"];
    
    self.collectDetailImage = [UIImage imageNamed:@"collectDetail"];
    self.collectDetailSelectedImage = [UIImage imageNamed:@"collectDetailSelected"];
    self.shareDetailImage = [UIImage imageNamed:@"shareDetail"];
    self.shareDetailSelectedImage = [UIImage imageNamed:@"shareDetailSelected"];
    
    self.collectFloatImage = [UIImage imageNamed:@"collectFloat"];
    self.collectFloatSelectedImage = [UIImage imageNamed:@"collectFloatSelected"];
    self.shareFloatImage = [UIImage imageNamed:@"shareFloat"];
    self.shareFloatSelectedImage = [UIImage imageNamed:@"shareFloatSelected"];
    
    self.editImage = [UIImage imageNamed:@"edit"];
    self.editSelectedImage = [UIImage imageNamed:@"editSelected"];
    self.completeImage = [UIImage imageNamed:@"complete"];
    self.completeSelectedImage = [UIImage imageNamed:@"completeSelected"];
    
    self.arrowRightGreyImage = [UIImage imageNamed:@"arrowRightGrey"];
    self.arrowRightWhiteImage = [UIImage imageNamed:@"arrowRightWhite"];
    
    self.infoImage = [UIImage imageNamed:@"info"];
    self.likeImage = [UIImage imageNamed:@"like"];
    self.heartImage = [UIImage imageNamed:@"heart"];
}

- (void)initTypeImages
{
    NSArray *types = @[@"food", @"fun", @"house", @"shopping", @"travel", @"sport", @"beauty"];
    
    NSMutableArray *briefTmp = [NSMutableArray arrayWithCapacity:(types.count + 1)];
    NSMutableArray *detailTmp = [NSMutableArray arrayWithCapacity:(types.count + 1)];
    NSMutableArray *collectTmp = [NSMutableArray arrayWithCapacity:(types.count + 1)];
    
    briefTmp[0] = [NSNull null];
    detailTmp[0] = [NSNull null];
    collectTmp[0] = [NSNull null];
    
    NSString *briefSuffix = @"Brief";
    NSString *detailSuffix = @"Detail";
    NSString *collectSuffix = @"Collect";
    
    for (NSString *type in types) {
        [briefTmp addObject:[UIImage imageNamed:[type stringByAppendingString:briefSuffix]]];
        [detailTmp addObject:[UIImage imageNamed:[type stringByAppendingString:detailSuffix]]];
        [collectTmp addObject:[UIImage imageNamed:[type stringByAppendingString:collectSuffix]]];
    }
    _briefTypeImages = [NSArray arrayWithArray:briefTmp];
    _detailTypeImages = [NSArray arrayWithArray:detailTmp];
    _collectTypeImages = [NSArray arrayWithArray:collectTmp];
}

- (UIImage *)briefTypeImage:(NSUInteger)type
{
    return self.briefTypeImages[type];
}

- (UIImage *)detailTypeImage:(NSUInteger)type
{
    return self.detailTypeImages[type];
}

- (UIImage *)collectTypeImage:(NSUInteger)type
{
    return self.collectTypeImages[type];
}

@end
