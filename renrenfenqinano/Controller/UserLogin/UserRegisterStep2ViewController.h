//
//  UserRegisterStep2ViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterStep2ViewController : UIViewController
- (IBAction)doBackAction:(id)sender;
- (IBAction)doResendAction:(id)sender;
- (IBAction)doNextAction:(id)sender;

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) BOOL isForgetPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtCaptcha;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UILabel *lblTip;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end
