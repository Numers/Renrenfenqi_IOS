//
//  BillPaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillPaymentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableList;

-(void)setCalRepaymentMoney:(NSNumber *)calRepayment;
@end
