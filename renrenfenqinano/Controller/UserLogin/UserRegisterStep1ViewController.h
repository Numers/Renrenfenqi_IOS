//
//  UserRegisterStep1ViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterStep1ViewController : UIViewController

- (IBAction)doBackAction:(id)sender;
- (IBAction)doAgreeAction:(id)sender;
- (IBAction)doNextAction:(id)sender;
- (IBAction)doAgreementAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAgree;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (nonatomic, assign) BOOL isAgree;
@end
