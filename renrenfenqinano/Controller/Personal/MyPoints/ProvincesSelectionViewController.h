//
//  ProvincesSelectionViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/1.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProvincesSelectionViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSMutableArray *dataArr;// 省 市 区 的列表显示数据
@property (strong, nonatomic) NSMutableArray *locationArr;// 省市区地址

@end
