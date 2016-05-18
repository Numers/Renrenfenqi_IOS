//
//  OrderConfirmViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingRedPaketViewController.h"

/**
    订单确认
 */

@interface OrderConfirmViewController : UIViewController <ShoppingRedPaketDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doNextAction:(id)sender;
- (IBAction)doGetRedPacket:(id)sender;

@property (strong, nonatomic) NSString *goodsID;
@property (strong, nonatomic) NSString *goodsName;
@property (strong, nonatomic) NSDictionary *goodsDetail;
@property (nonatomic, assign) float goodsPrice;
@property (nonatomic, assign) float firstPaymentRatio;
@property (nonatomic, assign) int fenqiNum;
@property (nonatomic, assign) float jobPrice;
@property (strong, nonatomic) NSString *jobType;

@property (strong, nonatomic) NSDictionary *orderParams1;
@property (strong, nonatomic) NSDictionary *orderParams2;

@property (weak, nonatomic) IBOutlet UITableView *tableOrder;

@end
