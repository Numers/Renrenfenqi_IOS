//
//  BillPaymentViewController.m
//  renrenfenqi
//
//  Created by coco on 15-5-5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "BillPaymentViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "Order.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DeductionViewController.h"
#import "MyBillsPaymentSuccessViewController.h"

@interface BillPaymentViewController () <DeductionDelegate,UITextFieldDelegate>{
    NSArray *_cellIDArr;
    NSNumber *calRepaymentMoney;
    NSNumber *payMoney;
    NSNumber *redpacketMoney;
    NSArray *redPacketList;
    float realPayMoney;
}

@end

@implementation BillPaymentViewController
-(void)setCalRepaymentMoney:(NSNumber *)calRepayment
{
    calRepaymentMoney = calRepayment;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
    
    payMoney = [NSNumber numberWithFloat:0.00f];
    redpacketMoney = [NSNumber numberWithFloat:0.00f];
    redPacketList = [NSArray array];
    realPayMoney = [calRepaymentMoney floatValue] - [redpacketMoney floatValue];
    
    _cellIDArr = @[@"CurRepaymentIdentifier", @"RedPacketIdentifier", @"RealRepaymentIdentifier", @"SeparatorIdentifier", @"RepaymentValueIdentifier",@"TipIdentifier", @"PaywayIdentifier"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.tableList reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)myTextFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = [notification object];
    if ((textField.text == nil) && (textField.text.length == 0)) {
        payMoney = [NSNumber numberWithFloat:0.00f];
    }else{
        payMoney = [NSNumber numberWithFloat:[textField.text floatValue]];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBack:(id)sender
{
    [AppUtils goBack:self];
}

-(IBAction)clickPayBtn:(id)sender
{
    if ([payMoney floatValue] <= 0 ) {
        [AppUtils showInfo:@"付款金额必须大于0"];
        return;
    }
    
    if ([payMoney floatValue] < realPayMoney ) {
        [AppUtils showInfo:@"付款金额必须大于等于实际应付款金额"];
        return;
    }
    
    [self getPaymentInfoFromAPI];
    
}

- (void)getPaymentInfoFromAPI
{
    NSDictionary *_accountInfo = [AppUtils getUserInfo];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSString *redPacketStr = @"";
    for (int i = 0; i < redPacketList.count; i++) {
        if (i == 0) {
            redPacketStr = redPacketList[i];
        }
        else
        {
            redPacketStr = [NSString stringWithFormat:@"%@,%@", redPacketStr, redPacketList[i]];
        }
    }
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"money":[NSString stringWithFormat:@"%.2f", [payMoney floatValue]],
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
            vc.payMoney = [payMoney floatValue];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        UIStoryboard *secondStory = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
        DeductionViewController *deductionVC = [secondStory instantiateViewControllerWithIdentifier:@"DeductionIdentifier"];
        deductionVC.delegate = self;
        [AppUtils pushPage:self targetVC:deductionVC];
    }
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3){
        return 10.0f;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _cellIDArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:_cellIDArr[indexPath.row] forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
        {
            UILabel *needPayLabel = (UILabel *)[cell viewWithTag:1];
            [needPayLabel setText:[NSString stringWithFormat:@"¥%.2f",[calRepaymentMoney floatValue]]];
        }
            break;
        case 1:
        {
            UILabel *redpocketLabel = (UILabel *)[cell viewWithTag:1];
            [redpocketLabel setText:[NSString stringWithFormat:@"已抵扣¥%.2f元",[redpacketMoney floatValue]]];
        }
            break;
        case 2:
        {
            
            UILabel *calRepaymentLabel = (UILabel *)[cell viewWithTag:1];
            [calRepaymentLabel setText:[NSString stringWithFormat:@"¥%.2f",realPayMoney]];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma -mark DeductionDelegate
-(void)repaymentRedData:(NSMutableArray *)redPakets totalValue:(int)money
{
    redpacketMoney = [NSNumber numberWithInt:money];
    redPacketList = [NSArray arrayWithArray:redPakets];
    realPayMoney = [calRepaymentMoney floatValue] - [redpacketMoney floatValue];
}
@end
