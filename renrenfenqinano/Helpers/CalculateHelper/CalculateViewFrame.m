//
//  CalculateViewFrame.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CalculateViewFrame.h"

@implementation CalculateViewFrame
#pragma mark - 视图位置计算
+(CGRect)viewFrame:(UINavigationController *)navigationController isShowNav:(BOOL)isShow withTabBarController:(UITabBarController *)tabBarOutController isShowTabBar:(BOOL)isShowTabBar
{
    CGRect frame;
    if([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7){
        //        [navigationController.navigationBar setTranslucent:NO];
    }
    float heightPadding;
    if (isShow) {
        if (navigationController == nil) {
            heightPadding      =  0;
        }else{
            [navigationController setNavigationBarHidden:NO];
            CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
            heightPadding      = statusBarViewRect.size.height + navigationController.navigationBar.frame.size.height;
        }
    }else{
        if (navigationController) {
            [navigationController setNavigationBarHidden:YES];
        }
        heightPadding = 0;
    }
    
    float height ;
    if (isShowTabBar) {
        if (tabBarOutController == nil) {
            height = 0;
        }else{
            height  = tabBarOutController.tabBar.frame.size.height;
        }
    }else{
        height = 0;
    }
    
    frame                    = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y - 0.5,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-height-heightPadding + 0.5);
    return frame;
}
@end
