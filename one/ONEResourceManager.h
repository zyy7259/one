//
//  ONEResourceManager.h
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEResourceManager : NSObject

@property UIImage *returnGrayImage;
@property UIImage *returnGraySelectedImage;
@property UIImage *editImage;
@property UIImage *editSelectedImage;
@property UIImage *completeImage;
@property UIImage *completeSelectedImage;

@property UIImage *infoImage;
@property UIImage *likeImage;
@property UIImage *heartImage;

@property UIImage *arrowRightGreyImage;
@property UIImage *arrowRightWhiteImage;

+ (ONEResourceManager *)sharedManager;

- (UIImage *)briefTypeImage:(NSUInteger)type;
- (UIImage *)detailTypeImage:(NSUInteger)type;
- (UIImage *)collectTypeImage:(NSUInteger)type;

@end
