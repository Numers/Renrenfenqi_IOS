//
//  CurMonthRepaymentViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurMonthRepaymentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableList;

@end
