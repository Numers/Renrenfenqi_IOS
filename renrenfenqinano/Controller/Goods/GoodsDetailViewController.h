//
//  GoodsDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-13.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"

@interface GoodsDetailViewController : UIViewController <SGFocusImageFrameDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)buyAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)moreRatesAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *imgsView;
@property (weak, nonatomic) IBOutlet UIView *evaluateView;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsName;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsPrice;
@property (weak, nonatomic) IBOutlet UITableView *tableEvaluate;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthPaymentTip;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@property (strong, nonatomic) NSString *goodsID;
@end
