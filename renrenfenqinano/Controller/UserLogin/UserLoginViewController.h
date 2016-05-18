//
//  UserLoginViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtils.h"

@interface UserLoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doCloseAction:(id)sender;
- (IBAction)doRegisterAction:(id)sender;
- (IBAction)doForgetPasswordAction:(id)sender;
- (IBAction)doLoginAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
//@property (weak, nonatomic) IBOutlet UITextField *txtUserAccount;
//@property (weak, nonatomic) IBOutlet UITextField *txtUserPassword;
@property (weak, nonatomic) IBOutlet UITableView *tableLogin;

@property (nonatomic, assign) WriteInfoMode writeInfoMode;
@property (nonatomic, assign) Class parentClass;
@property (nonatomic, strong) UIViewController *parentController;

@end
