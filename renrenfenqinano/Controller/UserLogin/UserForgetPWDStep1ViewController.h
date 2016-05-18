//
//  UserForgetPWDStep1ViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserForgetPWDStep1ViewController : UIViewController
- (IBAction)doBackAction:(id)sender;
- (IBAction)doNextAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end
