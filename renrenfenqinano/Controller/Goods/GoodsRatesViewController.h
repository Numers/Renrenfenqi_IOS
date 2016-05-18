//
//  GoodsRatesViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-9.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
    商品评价页
 */

@interface GoodsRatesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *goodsID;

- (IBAction)doBackAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableRates;

@end
