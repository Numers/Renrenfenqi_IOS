//
//  MyPointsViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPointsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *myPointsLabel;
@property (weak, nonatomic) IBOutlet UITableView *taskTableVIew;

@end
