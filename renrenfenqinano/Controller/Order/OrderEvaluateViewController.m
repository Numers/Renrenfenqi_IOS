//
//  OrderEvaluateViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderEvaluateViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"

@interface OrderEvaluateViewController ()
{
    int _generalRate;
    int _goodsRate;
    int _serviceRate;
    
    NSDictionary *_accountInfo;
}

@end

@implementation OrderEvaluateViewController

- (void)submitRate:(NSString *)theGeneralRate theGoodsRate:(NSString *)theGoodsRate theServiceRate:(NSString *)theServiceRate theContent:(NSString *)theContent
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"business_no":[self.order objectForKey:@"business_no"],
                                 @"star":theGeneralRate,
                                 @"goods_star":theGoodsRate,
                                 @"service_star":theServiceRate,
                                 @"content":theContent,
                                 @"goods_id":[self.order objectForKey:@"goods_id"]
                                 };
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_RATE] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:[self.order objectForKey:@"goods_id"]];
    [manager POST:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"评价成功"];
            
            [self doBackAction:nil];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _accountInfo = [AppUtils getUserInfo];
    
    [self.imgGoods sd_setImageWithURL:[NSURL URLWithString:[self.order objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    self.lblGoodsName.text = [self.order objectForKey:@"goods_name"];
    
    _generalRate = [self rateFiveStar:self.btnGeneralRate];
    _goodsRate = [self rateFiveStar:self.btnGoodsRate];
    _serviceRate = [self rateFiveStar:self.btnServiceRate];
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitRateAction:(id)sender {
    if (_generalRate < 2) {
        [AppUtils showInfo:@"总体评价至少一星"];
        return;
    }
    
    if (_goodsRate < 2) {
        [AppUtils showInfo:@"商品评价至少一星"];
        return;
    }
    
    if (_serviceRate < 2) {
        [AppUtils showInfo:@"服务评价至少一星"];
        return;
    }
    
    NSString *theRateContent = [AppUtils trimWhite:self.txtRateContent.text];
    if (theRateContent.length < 1) {
        [AppUtils showInfo:@"请输入评价内容"];
        return;
    }
    
    [self submitRate:[NSString stringWithFormat:@"%d", _generalRate] theGoodsRate:[NSString stringWithFormat:@"%d", _goodsRate] theServiceRate:[NSString stringWithFormat:@"%d", _serviceRate] theContent:theRateContent];
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (int)makeRate:(id)sender event:(UIEvent *)event {
    int rate=0;
    UIButton *btn = (UIButton *)sender;
    UITouch *touch = [[event touchesForView:btn] anyObject];
    CGPoint location = [touch locationInView:btn];
    
    if (location.x < 25.0) {
        [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star01_h"] forState:UIControlStateNormal];
        rate = 2;
    }
    else if (location.x < 50.0)
    {
        [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star02_h"] forState:UIControlStateNormal];
        rate = 4;
    }
    else if (location.x < 75.0)
    {
        [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star03_h"] forState:UIControlStateNormal];
        rate = 6;
    }
    else if (location.x < 100.0)
    {
        [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star04_h"] forState:UIControlStateNormal];
        rate = 8;
    }
    else if (location.x < 125.0)
    {
        [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star05_h"] forState:UIControlStateNormal];
        rate = 10;
    }
    return rate;
}

- (int)rateFiveStar:(id)sender
{
    int rate=0;
    UIButton *btn = (UIButton *)sender;
    [btn setImage:[UIImage imageNamed:@"orderevaluation_body_star05_h"] forState:UIControlStateNormal];
    rate = 10;
    
    return rate;
}

- (IBAction)generalRateAction:(id)sender forEvent:(UIEvent*)event {
    int rate = [self makeRate:sender event:event];
    _generalRate = rate;
}

- (IBAction)goodsRateAction:(id)sender forEvent:(UIEvent*)event
{
    int rate = [self makeRate:sender event:event];
    _goodsRate = rate;
}

- (IBAction)serviceRateAction:(id)sender forEvent:(UIEvent*)event
{
    int rate = [self makeRate:sender event:event];
    _serviceRate = rate;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:self.txtRateContent]) {
        [self.txtRateContent resignFirstResponder];
    }
    
    return YES;
}

@end
