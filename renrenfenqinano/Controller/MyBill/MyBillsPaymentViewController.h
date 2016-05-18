//
//  MyBillsPaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-3.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "DeductionViewController.h"

/**
    账单支付
 */

@interface MyBillsPaymentViewController : UIViewController <DeductionDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doPayAction:(id)sender;
- (IBAction)doGetRedPacket:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblPayMoney;
@property (weak, nonatomic) IBOutlet UILabel *lblRedPacketInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblRealPayMoney;
@property (weak, nonatomic) IBOutlet UITextField *txtInputPayMoney;


@property (strong, nonatomic) NSString *repaymentMoney;
@property (strong, nonatomic) NSDictionary *bill;

@end
