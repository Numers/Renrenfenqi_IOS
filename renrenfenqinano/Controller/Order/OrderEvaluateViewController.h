//
//  OrderEvaluateViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    订单评价
 */

@interface OrderEvaluateViewController : UIViewController <UITextFieldDelegate>
- (IBAction)submitRateAction:(id)sender;
- (IBAction)doBackAction:(id)sender;
//- (IBAction)generalRateAction:(id)sender;
- (IBAction)generalRateAction:(id)sender forEvent:(UIEvent*)event;
- (IBAction)goodsRateAction:(id)sender forEvent:(UIEvent*)event;
- (IBAction)serviceRateAction:(id)sender forEvent:(UIEvent*)event;
@property (weak, nonatomic) IBOutlet UITextField *txtRateContent;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIImageView *imgGoods;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsName;

@property (strong, nonatomic) NSDictionary* order;
@property (weak, nonatomic) IBOutlet UIButton *btnGeneralRate;
@property (weak, nonatomic) IBOutlet UIButton *btnGoodsRate;
@property (weak, nonatomic) IBOutlet UIButton *btnServiceRate;

@end
