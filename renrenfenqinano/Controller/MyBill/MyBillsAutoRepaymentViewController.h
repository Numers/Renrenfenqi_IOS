//
//  MyBillsAutoRepaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBillsBankSelectViewController.h"

/**
    代扣
 */


@interface MyBillsAutoRepaymentViewController : UIViewController <MyBillsBankSelectVCDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBankSelectAction:(id)sender;

- (IBAction)doBackAction:(id)sender;
- (IBAction)doAgreeAction:(id)sender;
- (IBAction)doAgreementAction:(id)sender;
- (IBAction)doSubmitAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtBankName;
@property (weak, nonatomic) IBOutlet UITextField *txtBankCard;
@property (weak, nonatomic) IBOutlet UITextField *txtIDCard;
@property (weak, nonatomic) IBOutlet UITextField *txtCardHolderName;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAgree;

@end
