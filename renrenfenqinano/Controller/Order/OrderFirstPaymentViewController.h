//
//  OrderFirstPaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    订单的首付
 */

@interface OrderFirstPaymentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)doBackAction:(id)sender;
- (IBAction)doPaymentAction:(id)sender;

@property (strong, nonatomic) NSDictionary *order;
@property (weak, nonatomic) IBOutlet UITableView *tablePayment;

-(void)setOrderDic:(NSDictionary *)dic;
@end
