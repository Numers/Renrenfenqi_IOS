//
//  CommonVariable.m
//  renrenfenqi
//
//  Created by DY on 15/2/5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CommonVariable.h"
#import "AppUtils.h"

@implementation CommonVariable

// 分享的默认使用图片
+ (UIImage *)defaultShareIcon {
    return  [UIImage imageNamed:@"defaultSharePic.png"];
}

// 只想兼职工种默认图片  130X130 pixel
+ (UIImage *)defaultJobIcon {
    return  [UIImage imageNamed:@"defaultSharePic.png"];
}

// 默认红色字体
+ (UIColor *)redFontColor {
    return UIColorFromRGB(0xfb6362);
}

// 默认灰色字体
+ (UIColor *)grayFontColor {
    return UIColorFromRGB(0xa2a2a2);
}

// 默认灰色背景颜色
+ (UIColor *)grayBackgroundColor {
    return UIColorFromRGB(0xf2f2f2);
}

// 默认红色背景颜色
+ (UIColor *)redBackgroundColor {
    return UIColorFromRGB(0xff7c7c);
}

// 默认灰色分割线颜色
+ (UIColor *)grayLineColor {
    return UIColorFromRGB(0xdfdfdf);
}

// 默认绿色字体
+ (UIColor *)greenFontColor {
    return UIColorFromRGB(0x6fd865);
}

@end
