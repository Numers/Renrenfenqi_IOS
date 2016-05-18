//
//  DeductionResultViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeductionResultViewController : UIViewController
{
    
}

@property (weak, nonatomic) IBOutlet UIView *circumcircle;
@property (weak, nonatomic) IBOutlet UIView *innercircle;
@property (weak, nonatomic) IBOutlet UILabel *deductionLabel; // 红色圆圈里的字
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;      // 提示语
@property (weak, nonatomic) IBOutlet UILabel *redmoneyLabel;  // 红包金额
@property (weak, nonatomic) IBOutlet UILabel *monthMoneyLabel;// 本月还款额度
@property (weak, nonatomic) IBOutlet UILabel *repaymentLabel;  // 实际还款额度


@property (assign, nonatomic) NSDictionary *billDic;
@property (assign, nonatomic) int redMoneyValue;

@end
