//
//  ShareView.h
//  renrenfenqi
//
//  Created by DY on 15/1/12.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView
{
    CALayer *_opacityLayer;
    UIView  *_mainView;
    NSArray *_shareButtonArr;
}

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) UIImage *thumbnail;

// 显示或关闭对话框
- (void)showDialog:(BOOL)bShow;

@end
