//
//  MyBillsViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    我的账单
 */

@interface MyBillsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doRepaymentAction:(id)sender;
- (IBAction)doAutoRepaymentAction:(id)sender;
- (IBAction)doBackAction:(id)sender;
- (IBAction)doMoreBillsAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *viewSegment;
@property (weak, nonatomic) IBOutlet UILabel *lblDebt;
@property (weak, nonatomic) IBOutlet UITableView *tableBill;
@property (weak, nonatomic) IBOutlet UILabel *lblRepayment;
@property (weak, nonatomic) IBOutlet UIButton *btnRepay;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreMonth;
@property (weak, nonatomic) IBOutlet UIView *blankView;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoRepayment;
@end
