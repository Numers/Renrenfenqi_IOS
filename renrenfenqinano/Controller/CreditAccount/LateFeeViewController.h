//
//  LateFeeViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RFBill;
@interface LateFeeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableList;
-(void)updateUIWithBill:(RFBill *)b;
-(void)updateUIWithBill:(RFBill *)b WithDays:(NSString *)days WithNeedPay:(NSString *)needPay;
@end
