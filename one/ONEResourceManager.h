//
//  ONEResourceManager.h
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEResourceManager : NSObject

@property UIImage *closeImage;
@property UIImage *closeImageSelected;
@property UIImage *returnImage;
@property UIImage *returnImageSelected;
@property UIImage *editImage;
@property UIImage *editImageSelected;
@property UIImage *completeImage;
@property UIImage *completeImageSelected;

+ (ONEResourceManager *)defaultManager;

- (UIImage *)briefTypeImage:(NSUInteger)type;
- (UIImage *)detailTypeImage:(NSUInteger)type;
- (UIImage *)collectTypeImage:(NSUInteger)type;

@end
