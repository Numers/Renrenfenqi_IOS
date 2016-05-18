//
//  BillDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RFBill;
@interface BillDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableList;
-(void)updateUIWithBill:(RFBill *)b;
@end
