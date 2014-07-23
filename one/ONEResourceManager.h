//
//  ONEResourceManager.h
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEResourceManager : NSObject

// onelife
@property UIImage *onelifeImage;
@property UIImage *onelifeArticleTmpImage;

// 灰色的返回按钮
@property UIImage *returnImage;
@property UIImage *returnSelectedImage;

// 嵌在详情页中的按钮
@property UIImage *collectDetailImage;
@property UIImage *collectDetailSelectedImage;
@property UIImage *shareDetailImage;
@property UIImage *shareDetailSelectedImage;
// 浮动在详情页上的按钮
@property UIImage *collectFloatImage;
@property UIImage *collectFloatSelectedImage;
@property UIImage *shareFloatImage;
@property UIImage *shareFloatSelectedImage;

// 编辑和完成按钮
@property UIImage *editImage;
@property UIImage *editSelectedImage;
@property UIImage *completeImage;
@property UIImage *completeSelectedImage;

// 用于设置UITableViewCell的accessoryVIew
@property UIImage *arrowRightGreyImage;
@property UIImage *arrowRightWhiteImage;

// 设置页面使用的三个图标
@property UIImage *aboutUsImage;
@property UIImage *likeUsImage;
@property UIImage *scoreUsImage;

@property UIImage *locationImage;

+ (ONEResourceManager *)sharedManager;

- (UIImage *)briefTypeImage:(NSUInteger)type;
- (UIImage *)detailTypeImage:(NSUInteger)type;
- (UIImage *)collectTypeImage:(NSUInteger)type;

@end
