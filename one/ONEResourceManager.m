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
    
    [self initButtonImages];
    [self initTypeImages];
    
    return self;
}

- (void)initButtonImages
{
    self.returnGreyImage = [UIImage imageNamed:@"returnGrey"];
    self.returnGreySelectedImage = [UIImage imageNamed:@"returnGreySelected"];
    self.editImage = [UIImage imageNamed:@"edit"];
    self.editSelectedImage = [UIImage imageNamed:@"editSelected"];
    self.completeImage = [UIImage imageNamed:@"complete"];
    self.completeSelectedImage = [UIImage imageNamed:@"completeSelected"];
    
    self.infoImage = [UIImage imageNamed:@"info"];
    self.likeImage = [UIImage imageNamed:@"like"];
    self.heartImage = [UIImage imageNamed:@"heart"];
    
    self.arrowRightGreyImage = [UIImage imageNamed:@"arrowRightGrey"];
    self.arrowRightWhiteImage = [UIImage imageNamed:@"arrowRightWhite"];
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
