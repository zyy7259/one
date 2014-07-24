//
//  ONEViewHelper.h
//  ONELife
//
//  Created by zyy on 14-7-22.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONEViewUtils : NSObject

+ (UILabel *)deepLabelCopy:(UILabel *)label;
+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing;
+ (CGRect)boundingRectWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;
+ (void)showHint:(NSString *)hint inViewController:(UIViewController *)viewController;
+ (CGFloat)tapDelay;
+ (UIColor *)usColor;

@end
