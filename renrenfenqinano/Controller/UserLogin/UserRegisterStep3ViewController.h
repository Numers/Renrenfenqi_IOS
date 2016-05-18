//
//  UserRegisterStep3ViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterStep3ViewController : UIViewController
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doSetPassword:(id)sender;

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *captcha;
@property (nonatomic, assign) BOOL isForgetPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswordAgain;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;

@end
