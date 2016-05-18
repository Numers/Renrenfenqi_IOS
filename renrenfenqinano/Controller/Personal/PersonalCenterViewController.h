//
//  PersonalCenterViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFStretchableTableHeaderView.h"

@interface PersonalCenterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *excircleView;  // 白色外圆
@property (weak, nonatomic) IBOutlet UIButton *headPicBtn;  // 头像按钮
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;// 昵称
@property (weak, nonatomic) IBOutlet UIButton *signBtn;     // 没登录显示注册和登录，

@property (weak, nonatomic) IBOutlet UIImageView *grayBackground;

@property (nonatomic, strong) HFStretchableTableHeaderView* stretchableTableHeaderView;

@end
