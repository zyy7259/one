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

+ (ONEResourceManager *)defaultManager
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
    self.closeImage = [UIImage imageNamed:@"close"];
    self.closeImageSelected = [UIImage imageNamed:@"closeSelected"];
    self.returnImage = [UIImage imageNamed:@"return"];
    self.returnImageSelected = [UIImage imageNamed:@"returnSelected"];
    self.editImage = [UIImage imageNamed:@"edit"];
    self.editImageSelected = [UIImage imageNamed:@"editSelected"];
    self.completeImage = [UIImage imageNamed:@"complete"];
    self.completeImageSelected = [UIImage imageNamed:@"completeSelected"];
}

- (void)initTypeImages
{
    _briefTypeImages = [NSArray arrayWithObjects:
                        [NSNull null],
                        [UIImage imageNamed:@"foodBrief"],
                        [UIImage imageNamed:@"foodBrief"],
                        [UIImage imageNamed:@"foodBrief"],
                        [UIImage imageNamed:@"foodBrief"],
                        nil];
    _detailTypeImages = [NSArray arrayWithArray:_briefTypeImages];
    _collectTypeImages = [NSArray arrayWithArray:_briefTypeImages];
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
