//
//  SecondViewController.h
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
    商品目录页
 */

@interface CategoriesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doSearchAction:(id)sender;
//@property (weak, nonatomic) IBOutlet UITableView *categoryList;


@property (weak, nonatomic) IBOutlet UITableView *tableCategories;

@end

