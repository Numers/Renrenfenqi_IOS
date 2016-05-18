//
//  OrderJobPaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 15-1-28.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderJobPaymentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)doBackAction:(id)sender;

- (IBAction)doPaymentAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tablePayment;

@property (strong, nonatomic) NSString *businessNO;
@property (strong, nonatomic) NSString *paymentMoney;
@end
