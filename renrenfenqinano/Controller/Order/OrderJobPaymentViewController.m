//
//  OrderJobPaymentViewController.m
//  renrenfenqi
//
//  Created by coco on 15-1-28.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "OrderJobPaymentViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "Order.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import <AlipaySDK/AlipaySDK.h>

@interface OrderJobPaymentViewController ()
{
    int _cellHeightArr[6];
    NSArray *_cellIDArr;
    
    float _viewWidth;
    float _viewHeight;
    
    NSDictionary *_accountInfo;
}

@end

@implementation OrderJobPaymentViewController

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
        order.notifyURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, ALIPAY_JOYPAY_NOTIFY]; //回调URL
        
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
                //                MyLog(@"reslut = %@",resultDic);
                
                [self handleAlipayResult:resultDic];
            }];
            
        }
    }
}

- (void)handleAlipayResult:(NSDictionary *)resultDic
{
    if (resultDic)
    {
        if ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000)
        {
            [AppUtils showSuccess:@"支付成功！"];
            
            [self doBackAction:self];
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

- (void)handleAlipayCallBack:(NSNotification*) notification
{
    if ([notification object]) {
        [self handleAlipayResult:[notification object]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _accountInfo = [AppUtils getUserInfo];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _cellHeightArr[0] = 43.0;
    _cellHeightArr[1] = 10.0;
    _cellHeightArr[2] = 43.0;
    _cellHeightArr[3] = 10.0;
    _cellHeightArr[4] = 43.0;
    _cellHeightArr[5] = 600.0;
    _cellIDArr = @[@"PayMoneyIdentifier", @"SeparatorIdentifier", @"TipIdentifier", @"SeparatorIdentifier", @"PayTypeIdentifier", @"PayActionIdentifier"];
    
    self.tablePayment.dataSource = self;
    self.tablePayment.delegate = self;
    self.tablePayment.tableFooterView = [UIView new];
//    self.tablePayment.backgroundColor = [UIColor clearColor];
    if ([self.tablePayment respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tablePayment setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tablePayment respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tablePayment setLayoutMargins:UIEdgeInsetsZero];
    }
    
    UIView *lineView = [AppUtils makeLine:_viewWidth theTop:64.0];
    [self.view addSubview:lineView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAlipayCallBack:)
                                                 name:NOTIFY_ALIPAY_CALLBACK
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeightArr[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIDArr[indexPath.row] forIndexPath:indexPath];
    

        switch (indexPath.row) {
            case 0:
            {
                UILabel *lblPaymentMoney = (UILabel *)[cell viewWithTag:1];
                lblPaymentMoney.text = [NSString stringWithFormat:@"¥%@", self.paymentMoney];
            }
                break;
                
            default:
                break;
        }

    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

/**
    从服务器获取支付宝用订单号后，进行支付宝支付
 */
- (void)doAlipayment
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"business_no":self.businessNO
                                 };
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, JOBPAY_PAYINFO];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//                MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            NSDictionary *thePaymentInfo = [jsonData objectForKey:@"data"];
            
            if (thePaymentInfo) {
                [self doRepayment:thePaymentInfo];
            }
            
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (IBAction)doPaymentAction:(id)sender {
    [self doAlipayment];
}
@end
