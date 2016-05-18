//
//  CommonTools.m
//  renrenfenqi
//
//  Created by DY on 15/1/4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CommonTools.h"
#import "CommonVariable.h"

@implementation CommonTools

+ (void)NsLogFromFrame:(CGRect) frame {
    NSLog(@"x:%1f y:%1f w:%1f h:%1f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

//只有标题
+ (UIView *)generateTopBarWiwhOnlyTitle:(id)target title:(NSString*)title {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _MainScreen_Width, 64)];
    topView.backgroundColor = [CommonVariable grayBackgroundColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(60,20, topView.frame.size.width - 120, 44);
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = GENERAL_FONT18;
    titleLabel.textColor = [UIColor blackColor];
    [topView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [CommonVariable grayLineColor];
    line.frame = CGRectMake(0, topView.frame.size.height - 0.5, topView.frame.size.width, 0.5);
    [topView addSubview:line];
    
    return topView;
}
// 只有返回按钮和标题
+ (UIView *)generateTopBarWiwhOnlyBackButton:(id)target title:(NSString*)title action:(SEL)back_action {
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _MainScreen_Width, 64)];
    topView.backgroundColor = [CommonVariable grayBackgroundColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(60,20, topView.frame.size.width - 120, 44);
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = GENERAL_FONT18;
    titleLabel.textColor = [UIColor blackColor];
    [topView addSubview:titleLabel];
    
    UIButton* button_back = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [button_back setImage:[UIImage imageNamed:@"common_back_h@2x.png"] forState:UIControlStateNormal];
    [button_back addTarget:target action:back_action forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:button_back];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [CommonVariable grayLineColor];
    line.frame = CGRectMake(0, topView.frame.size.height - 0.5, topView.frame.size.width, 0.5);
    [topView addSubview:line];
    
    return topView;
    
}

+ (NSString*)encodeAsURIComponent:(NSString *)str
{
    NSString *res = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return res;
}

+ (NSString *)decodeFromURLComponent:(NSString *)str
{
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

// 解析活动url
+ (NSDictionary *)activityUrlInfo:(NSString *)url
{
    /* 活动url 模板规则
     http://test.m.renrenfenqi.com/spage/activity/t1/20150204_12.html
     */
    NSString *activityType = @"";
    NSString *activityId = @"";
    NSRange range = [url rangeOfString:@"activity"];
    if (range.length > 0) {
        url = [url substringFromIndex:range.location];
        range = [url rangeOfString:@".html"];
        if (range.length > 0) {
            url = [url substringToIndex:range.location];
            NSArray *vals = [url componentsSeparatedByString:@"/"];
            if (vals.count > 1) {
                activityType = [NSString stringWithFormat:@"%@", [vals objectAtIndex:1]];
            }
            if (vals.count > 2) {
                NSString *tempStr = [NSString stringWithFormat:@"%@", [vals objectAtIndex:2]];
                range = [tempStr rangeOfString:@"_"];
                tempStr = [tempStr substringFromIndex:range.location + range.length];
                activityId = tempStr;
            }
        }
    }
   
    NSDictionary *activityUrlInfo = @{@"activityType":activityType, @"activityId":activityId};
    return activityUrlInfo;
}

@end
