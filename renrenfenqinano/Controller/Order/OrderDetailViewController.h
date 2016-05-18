//
//  OrderDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    我的订单，订单中的订单明细
 */

@interface OrderDetailViewController : UIViewController
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doRateAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstPayment;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthPayment;
@property (weak, nonatomic) IBOutlet UILabel *lblPeriods;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsName;
@property (weak, nonatomic) IBOutlet UIImageView *imgGoods;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderNo;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *lblUserInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgOrderState;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStateStep1;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStateStep2;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStateStep3;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStateStep4;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderStateStep5;

@property (strong, nonatomic) NSDictionary* order;

@end
