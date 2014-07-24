//
//  ONEViewHelper.m
//  ONELife
//
//  Created by zyy on 14-7-22.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEViewUtils.h"

static UILabel *hintLabel = nil;

@implementation ONEViewUtils

+ (UILabel *)deepLabelCopy:(UILabel *)label
{
    UILabel *l = [[UILabel alloc] initWithFrame:label.frame];
    l.text = label.text;
    l.textColor = label.textColor;
    l.font = label.font;
    return l;
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color lineSpacing:(CGFloat)lineSpacing
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSFontAttributeName value:font range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setAlignment:NSTextAlignmentJustified];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

+ (CGRect)boundingRectWithString:(NSString *)string width:(CGFloat)width font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing
{
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    return [string boundingRectWithSize:maxSize
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle}
                                context:nil];
}

+ (void)showHint:(NSString *)hint inViewController:(UIViewController *)viewController
{
    if (hintLabel == nil) {
        hintLabel = [UILabel new];
        hintLabel.font = [UIFont systemFontOfSize:18];
        hintLabel.textColor = [UIColor whiteColor];
        hintLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.layer.cornerRadius = 10;
    }
    hintLabel.text = hint;
    [hintLabel sizeToFit];
    CGRect frame = hintLabel.frame;
    frame.size.width += 40;
    frame.size.height += 20;
    hintLabel.frame = frame;
    hintLabel.center = viewController.view.center;
    [viewController.view addSubview:hintLabel];
    [UIView animateWithDuration:0.4 animations:^{
        hintLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [hintLabel removeFromSuperview];
    }];
}

+ (CGFloat)tapDelay
{
    return 0.2;
}

+ (UIColor *)usColor
{
    return [UIColor colorWithRed:66/255.0 green:217/255.0 blue:213/255.0 alpha:1.0];
}

@end
