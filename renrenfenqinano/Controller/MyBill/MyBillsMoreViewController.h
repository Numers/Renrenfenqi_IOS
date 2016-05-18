//
//  BillMoreViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    账单中的更多
 */

@interface MyBillsMoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)doBackAction:(id)sender;

@property (weak, nonatomic) NSDictionary *bills;

@property (weak, nonatomic) IBOutlet UITableView *tableMore;

@end
