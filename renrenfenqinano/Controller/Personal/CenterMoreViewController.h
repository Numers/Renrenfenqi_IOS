//
//  CenterMoreViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterMoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableview;

@end
