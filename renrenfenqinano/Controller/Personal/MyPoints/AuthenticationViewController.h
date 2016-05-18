//
//  AuthenticationViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SchoolListViewController.h"

@interface AuthenticationViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,SchoolListDelegate>


@property (weak, nonatomic) IBOutlet UITextField *nameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *identityCardTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *studentIDTextFiled;
@property (weak, nonatomic) IBOutlet UITableView *schoolTableview;// 用于所属地和学校显示
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end
