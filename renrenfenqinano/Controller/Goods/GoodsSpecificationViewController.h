//
//  GoodsSpecificationViewController.h
//  renrenfenqi
//
//  Created by coco on 14-11-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsSpecificationViewController : UIViewController
{
    NSUserDefaults* persistentDefaults;
}
- (IBAction)doBackAction:(id)sender;
- (IBAction)doBuyAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) NSString *goodsID;
@property (weak, nonatomic) NSDictionary *goodsDetail;

@property (weak, nonatomic) IBOutlet UIImageView *goodsImg;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsName;
@property (weak, nonatomic) IBOutlet UILabel *lblGoodsPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthPayment;
@property (weak, nonatomic) IBOutlet UIView *contentView;


@end
