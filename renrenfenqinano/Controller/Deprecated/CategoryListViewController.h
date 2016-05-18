//
//  CategoryListViewController.h
//  renrenfenqinano
//
//  Created by coco on 14-11-12.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (IBAction)backAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *goodsList;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *brandID;
@property (strong, nonatomic) NSString *type;

@end
