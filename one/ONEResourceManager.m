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
