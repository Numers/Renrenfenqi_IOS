//
//  JobDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-24.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (IBAction)doBackAction:(id)sender;
- (IBAction)doJobApplyAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableDetail;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (strong, nonatomic) NSString *jobDeailId;
@property (nonatomic, assign) BOOL isHideJobApply;

@end
