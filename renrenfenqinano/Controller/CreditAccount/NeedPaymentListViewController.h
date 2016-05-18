//
//  NeedPaymentListViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NeedPaymentListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableList;

@end
