//
//  SchoolListViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/1.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SchoolListDelegate <NSObject>

// 学校选择
- (void)selectSchool:(NSDictionary*)schoolDic;

@end

@interface SchoolListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *schoolArr;//
@property (weak, nonatomic) IBOutlet UITableView *shoolTableView;

@property (weak ,nonatomic) id <SchoolListDelegate> delegate;


@end
