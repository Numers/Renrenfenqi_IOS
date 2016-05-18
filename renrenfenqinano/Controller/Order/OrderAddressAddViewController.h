//
//  OrderAddressAddViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-17.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressSelectViewController.h"

/**
    没有地址时，添加地址
 */

@interface OrderAddressAddViewController : UIViewController <AddressSelectVCDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
- (IBAction)doBackAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableList;
@property (assign, nonatomic) BOOL isNeedJudge;

@end
