//
//  CreditAccountViewController.h
//  renrenfenqi
//
//  Created by coco on 15-4-28.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableList;

@end
