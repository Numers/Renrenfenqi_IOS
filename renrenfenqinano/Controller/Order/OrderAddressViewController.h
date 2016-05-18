//
//  OrderAddressViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-17.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
    地址确认
 */

@interface OrderAddressViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}
- (IBAction)doSubmitAction:(id)sender;
- (IBAction)doBackAction:(id)sender;

@property (strong, nonatomic) NSString *goodsID;
@property (strong, nonatomic) NSString *redPacketID;
@property (nonatomic, assign) float firstPaymentRatio;
@property (nonatomic, assign) int periods;
@property (nonatomic, assign) int jobDays;
@property (strong, nonatomic) NSString *jobType;

@property (strong, nonatomic) NSDictionary *orderParams;

@property (nonatomic, assign) BOOL isSubmitHidden;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UITableView *addressList;
@end
