//
//  CalculateViewFrame.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CalculateViewFrame : NSObject
+(CGRect)viewFrame:(UINavigationController *)navigationController isShowNav:(BOOL)isShow withTabBarController:(UITabBarController *)tabBarOutController isShowTabBar:(BOOL)isShowTabBar;
@end
