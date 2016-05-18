//
//  MyOrdersViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    我的订单
 */

@interface MyOrdersViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

@property (weak, nonatomic) IBOutlet UITableView *orderList;
@property (weak, nonatomic) IBOutlet UIView *blankView;
- (IBAction)doFirstPaymentAction:(id)sender;
- (IBAction)doJobPaymentAction:(id)sender;

- (IBAction)backAction:(id)sender;
@end
