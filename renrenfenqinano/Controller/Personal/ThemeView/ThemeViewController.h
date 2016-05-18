//
//  ThemeViewController.h
//  renrenfenqi
//
//  Created by DY on 15/1/9.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MenuBtnTag) {
    MenuBtnTag_Praise,
    MenuBtnTag_Share,
    MenuBtnTag_Comment,
};

@interface ThemeViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *activityID;
@property (strong, nonatomic) UIImage *thumbnail;

@end
