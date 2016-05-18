//
//  CommonTools.h
//  renrenfenqi
//
//  Created by DY on 15/1/4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppUtils.h"

@interface CommonTools : NSObject
// 打印frame
+ (void)NsLogFromFrame:(CGRect) frame;
//只有标题
+ (UIView *)generateTopBarWiwhOnlyTitle:(id)target title:(NSString*)title;
// 只有返回按钮和标题
+ (UIView *)generateTopBarWiwhOnlyBackButton:(id)target title:(NSString*)title action:(SEL)back_action;

+ (NSString *) encodeAsURIComponent:(NSString *)str;
+ (NSString *) decodeFromURLComponent:(NSString *)str;

// 压缩图片
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

// 解析活动url
+ (NSDictionary *)activityUrlInfo:(NSString *)url;
@end
