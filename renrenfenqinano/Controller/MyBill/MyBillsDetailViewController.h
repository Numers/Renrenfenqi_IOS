//
//  MyBillsDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    账单明细
 */

@interface MyBillsDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)doBackAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableDetail;

@property (strong, nonatomic) NSDictionary *lastBillDetail;
@property (strong, nonatomic) NSDictionary *curBillDetail;

@end
