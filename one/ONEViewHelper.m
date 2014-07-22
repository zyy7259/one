//
//  ONEViewHelper.m
//  ONELife
//
//  Created by zyy on 14-7-22.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONEViewHelper.h"

@implementation ONEViewHelper

+ (UILabel *)deepLabelCopy:(UILabel *)label
{
    UILabel *l = [[UILabel alloc] initWithFrame:label.frame];
    l.text = label.text;
    l.textColor = label.textColor;
    l.font = label.font;
    return l;
}

@end
