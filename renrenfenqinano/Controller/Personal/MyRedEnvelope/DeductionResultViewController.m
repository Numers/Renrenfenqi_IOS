//
//  DeductionResultViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "DeductionResultViewController.h"
#import "RedPacketViewController.h"
#import "AppDelegate.h"
#import "AppUtils.h"
#import "CommonWebViewController.h"

@interface DeductionResultViewController ()

@end

@implementation DeductionResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.circumcircle.layer.cornerRadius = 50.0f;
    self.circumcircle.layer.masksToBounds = YES;
    self.innercircle.layer.cornerRadius = 42.5f;
    self.innercircle.layer.masksToBounds = YES;
    
    // 设置界面数据
    float monthMony = [[[self.billDic objectForKey:@"now"] objectForKey:@"repayment_money"] floatValue];
    float actualMoney = monthMony - self.redMoneyValue;
    self.deductionLabel.text = [NSString stringWithFormat:@"%d",self.redMoneyValue];
    self.redmoneyLabel.text = [NSString stringWithFormat:@"红包抵扣额：￥%d",self.redMoneyValue];
    self.monthMoneyLabel.text = [NSString stringWithFormat:@"本月还款额：￥%0.2f",monthMony];
    self.repaymentLabel.text =[NSString stringWithFormat:@"实际还款额：￥%0.2f",actualMoney];
    self.tipsLabel.text = [NSString stringWithFormat:@"将在协议还款日从设置的自动还款银行卡扣取%0.2f元", actualMoney];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender
{
    [AppUtils goBack:self];
}

- (IBAction)useRule:(id)sender
{
    CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_RED_USE_ROLE;
    vc.titleString = @"红包使用规则";
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)finishDeduction:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[RedPacketViewController class]]) {
            [AppUtils popToPage:self targetVC:controller];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
