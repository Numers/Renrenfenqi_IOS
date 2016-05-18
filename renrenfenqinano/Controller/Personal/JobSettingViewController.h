//
//  JobSettingViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-25.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobSettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (IBAction)doBackAction:(id)sender;
- (IBAction)doModifySetting:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableJobSetting;
@property (weak, nonatomic) IBOutlet UIButton *btnModifySetting;

@property (strong, nonatomic) NSDictionary *myjobSetting;
@end
