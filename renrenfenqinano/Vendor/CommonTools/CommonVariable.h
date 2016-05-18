//
//  CommonVariable.h
//  renrenfenqi
//
//  Created by DY on 15/2/5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 此类用于管理各种默认的参数设置
 */

#define Iphone5Width     320
#define Iphone5Height    568

@interface CommonVariable : NSObject

// 分享的默认使用图片
+ (UIImage *)defaultShareIcon;
// 只想兼职工种默认图片  130X130 pixel
+ (UIImage *)defaultJobIcon;

// 默认绿色字体
+ (UIColor *)greenFontColor;
// 默认红色字体
+ (UIColor *)redFontColor;
// 默认灰色字体
+ (UIColor *)grayFontColor;
// 默认灰色背景颜色
+ (UIColor *)grayBackgroundColor;
// 默认红色背景颜色
+ (UIColor *)redBackgroundColor;
// 默认灰色分割线颜色
+ (UIColor *)grayLineColor;

@end
