//
//  MyBillsPaymentViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-3.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsPaymentViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "Order.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import "MyBillsPaymentSuccessViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DeductionViewController.h"

@interface MyBillsPaymentViewController ()
{
    float _redPacketMoney;
    float _realCurPeriodPayMoney;
    float _payMoney;
    
    NSMutableArray *_curRedPackets;
    int _curRedPacketsMoney;
    
    NSDictionary *_accountInfo;
}

@end

@implementation MyBillsPaymentViewController

- (void)handleAlipayResult:(NSDictionary *)resultDic
{
    //                                MyLog(@"reslut = %@",resultDic);
    
    if (resultDic)
    {
        if ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000)
        {
            //成功叻才重新获取账单
            [AppUtils showSuccess:@"还款成功！"];
            
            MyBillsPaymentSuccessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsPaymentSuccessIdentifier"];
            vc.payMoney = _payMoney;
            [AppUtils pushPage:self targetVC:vc];
            
        }
        else
        {
            //交易失败
            [AppUtils showInfo:@"交易取消或还款失败"];
        }
    }
    else
    {
        //失败
        [AppUtils showInfo:@"还款失败!"];
    }
}

- (void)doRepayment:(NSDictionary *)paymentInfo
{
    if (YES) {    //支付宝支付
        //partner和seller获取失败,提示
        if ([PartnerID length] == 0 || [SellerID length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"缺少partner或者seller。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        Order *order = [[Order alloc] init];
        order.partner = PartnerID;
        order.seller = SellerID;
        order.tradeNO = [paymentInfo objectForKey:@"repaybusinessno"]; //订单ID（由商家自行制定）
        order.productName = [paymentInfo objectForKey:@"desc"]; //商品标题
        order.productDescription = [paymentInfo objectForKey:@"desc"]; //商品描述
        order.amount = [NSString stringWithFormat:@"%.2f",[[paymentInfo objectForKey:@"money"] floatValue]]; //商品价格
        order.notifyURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, ALIPAY_NOTIFY]; //回调URL
        
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        order.showUrl = @"m.alipay.com";
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        NSString *appScheme = @"RRFQIOSClient";
        
        //将商品信息拼接成字符串
        NSString *orderSpec = [order description];
        //        MyLog(@"orderSpec = %@",orderSpec);
        
        //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
        id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
        NSString *signedString = [signer signString:orderSpec];
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = nil;
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, @"RSA"];
            
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic){
                [self handleAlipayResult:resultDic];
            }];
        
            
        }
    }
}


- (void)getPaymentInfoFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSString *redPacketStr = @"";
    for (int i = 0; i < _curRedPackets.count; i++) {
        if (i == 0) {
            redPacketStr = _curRedPackets[i];
        }
        else
        {
            redPacketStr = [NSString stringWithFormat:@"%@,%@", redPacketStr, _curRedPackets[i]];
        }
    }
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"money":[NSString stringWithFormat:@"%.2f", _payMoney],
                                 @"red_list":redPacketStr
                                 };
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, BILLS_ALIPAY];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            [self doRepayment:[jsonData objectForKey:@"data"]];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)resignAllFirstResponder{
    [self.view endEditing:YES];
}

- (void)handleAlipayCallBack:(NSNotification*) notification
{
    if ([notification object]) {
        [self handleAlipayResult:[notification object]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
//    _viewWidth = self.view.bounds.size.width;
//    _viewHeight = self.view.bounds.size.height;
    
    _curRedPackets = [NSMutableArray array];
    _curRedPacketsMoney = 0;
    
    _accountInfo = [AppUtils getUserInfo];
    
    _realCurPeriodPayMoney = [self.repaymentMoney floatValue];
    self.repaymentMoney = [NSString stringWithFormat:@"%0.2f", [[self.bill objectForKey:@"cal_repayment_money"] floatValue] - [[self.bill objectForKey:@"sum_pay_money"] floatValue]];
    self.lblPayMoney.text = [AppUtils makeMoneyString:self.repaymentMoney];
    self.lblRealPayMoney.text = [AppUtils makeMoneyString:self.repaymentMoney];
    _payMoney = _realCurPeriodPayMoney;
    
    //TODO
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAlipayCallBack:)
                                                 name:NOTIFY_ALIPAY_CALLBACK
                                               object:nil];
    
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma 还款红包多选
- (void)repaymentRedData:(NSMutableArray*)redPakets totalValue:(int)money
{
    MyLog(@"ddddddddd");
    _curRedPackets = redPakets;
    _curRedPacketsMoney = money;
    if (_curRedPacketsMoney > 0) {
        _realCurPeriodPayMoney = [self.repaymentMoney floatValue] - _curRedPacketsMoney;
        self.lblRedPacketInfo.text = [NSString stringWithFormat:@"已抵扣¥%d.00元", _curRedPacketsMoney];
        self.lblRealPayMoney.text = [NSString stringWithFormat:@"¥%.2f", _realCurPeriodPayMoney];
    }
    else
    {
        self.lblRedPacketInfo.text = @"";
        _realCurPeriodPayMoney = [self.repaymentMoney floatValue];
        self.lblRedPacketInfo.text = @"";
        self.lblRealPayMoney.text = [NSString stringWithFormat:@"¥%.2f", _realCurPeriodPayMoney];
    }
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doPayAction:(id)sender {
    NSString *theInputPayMoney = [AppUtils trimWhite:self.txtInputPayMoney.text];
    float theMoney = [theInputPayMoney floatValue];
    if ([theInputPayMoney isEqualToString:@""]) {
        [AppUtils showInfo:@"付款金额不能为空"];
        return;
    }
    
    if (theMoney <= 0 ) {
        [AppUtils showInfo:@"付款金额必须大于0"];
        return;
    }
    
    if (theMoney < _realCurPeriodPayMoney ) {
        [AppUtils showInfo:@"付款金额必须大于等于实际应付款金额"];
        return;
    }
    
    _payMoney = theMoney;
    
    [self getPaymentInfoFromAPI];
}

- (IBAction)doGetRedPacket:(id)sender {
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    DeductionViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"DeductionIdentifier"];
    vc.delegate = self;
    vc.selectedRedPacketArr = _curRedPackets;
    [AppUtils pushPage:self targetVC:vc];
}


@end
