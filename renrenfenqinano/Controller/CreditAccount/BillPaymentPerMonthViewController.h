//
//  BillPaymentPerMonthViewController.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/6.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillPaymentPerMonthViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableList;
-(void)setMonth:(NSString *)month WithType:(NSString *)type;
@end
