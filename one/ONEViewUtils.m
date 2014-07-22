//
//  ONEViewHelper.m
//  ONELife
//
//  Created by zyy on 14-7-22.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEViewUtils.h"

@implementation ONEViewUtils

+ (UILabel *)deepLabelCopy:(UILabel *)label
{
    UILabel *l = [[UILabel alloc] initWithFrame:label.frame];
    l.text = label.text;
    l.textColor = label.textColor;
    l.font = label.font;
    return l;
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:17];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return attributedString;
}

+ (CGRect)boundingRectWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font
{
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:17];
    return [string boundingRectWithSize:maxSize
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle}
                                context:nil];
}

@end
