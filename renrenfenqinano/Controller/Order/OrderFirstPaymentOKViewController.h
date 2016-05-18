//
//  OrderFirstPaymentOKViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderFirstPaymentOKViewController : UIViewController
- (IBAction)doOKAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *rectView;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMoney;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImg;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsName;

@property (strong, nonatomic) NSDictionary *order;

@end
