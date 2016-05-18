//
//  MyBillsPaymentSuccessViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    账单支付成功后
 */

@interface MyBillsPaymentSuccessViewController : UIViewController

- (IBAction)doBillDetailAction:(id)sender;
- (IBAction)doGoAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UILabel *lblRepaymentMoney;

@property (assign, nonatomic) float payMoney;

@end
