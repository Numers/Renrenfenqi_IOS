//
//  MyBillsBankSelectViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyBillsBankSelectVCDelegate.h"

/**
    代扣银行选择
 */

@interface MyBillsBankSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)doBackAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableBanks;

@property (nonatomic, assign) id <MyBillsBankSelectVCDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *selectedBank;

@end
