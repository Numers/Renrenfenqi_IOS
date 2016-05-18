//
//  OrderDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "OrderEvaluateViewController.h"

@interface OrderDetailViewController ()
{
    NSDictionary *_accountInfo;
    NSDictionary *_address;
    
    NSMutableArray *_trackArr;
    NSMutableArray *_rateArr;
    NSArray *_lblTrackArr;
}

@end

@implementation OrderDetailViewController

- (void)updateAddressUI
{
    self.lblUserInfo.text = [NSString stringWithFormat:@"%@          %@", [_address objectForKey:@"name"], [_address objectForKey:@"phone"]];
    self.lblAddress.text = [NSString stringWithFormat:@"%@%@", [_address objectForKey:@"school_name"], [_address objectForKey:@"dorm_address"]];
    
}

- (void)updateTrackUI
{
    int trackCount = MIN(_trackArr.count, _lblTrackArr.count);
    for (int i = 0; i < trackCount; i++) {
        NSDictionary *theTrack = [_trackArr objectAtIndex:i];
        UILabel *theLblTrack = [_lblTrackArr objectAtIndex:i];
        theLblTrack.text = [NSString stringWithFormat:@"%@ %@", [theTrack objectForKey:@"create_time"], [theTrack objectForKey:@"status_name"]];
        [theLblTrack setTextColor:GENERAL_COLOR_RED];
    }
}

- (void)getOrderTrackFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"business_no":[self.order objectForKey:@"business_no"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_BASE, ORDER_TRACK];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            id temp = [jsonData objectForKey:@"data"];
            if ([temp isKindOfClass:[NSArray class]]) {
                _trackArr = [jsonData objectForKey:@"data"];
                [self updateTrackUI];
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

- (void)getOrderGoodsRateFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"business_no":[self.order objectForKey:@"business_no"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GET_GOODS_RATE] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:[self.order objectForKey:@"goods_id"]];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _rateArr = [jsonData objectForKey:@"data"];
            
            if (_rateArr.count == 0 && [[_order objectForKey:@"status_msg"] isEqualToString:@"交易完成"]) {
                self.btnRate.enabled = YES;
                [self.btnRate setTintColor:GENERAL_COLOR_RED];
                [self.btnRate setTitle:@"评价" forState:UIControlStateNormal];
            }
            else if(_rateArr.count > 0)
            {
                [self.btnRate setTitle:@"已评价" forState:UIControlStateNormal];
            }
        }
        else if ([@"404" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]])
        {
            //do nothing
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getUserAddressFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_BASE, USER_ADDRESS];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _address = [jsonData objectForKey:@"data"];
            
            [self updateAddressUI];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    _trackArr = [NSMutableArray array];
    _rateArr = [NSMutableArray array];
    
    _lblTrackArr = @[self.lblOrderStateStep1, self.lblOrderStateStep2, self.lblOrderStateStep3, self.lblOrderStateStep4, self.lblOrderStateStep5];
    
    self.btnRate.enabled = NO;
    [self.btnRate setTintColor:GENERAL_COLOR_GRAY2];
    [self.btnRate setTitle:@"" forState:UIControlStateNormal];
    
    for (id lblItem in _lblTrackArr) {
        UILabel *lblTrack = (UILabel *)lblItem;
        lblTrack.text = @"";
    }
    
    _accountInfo = [AppUtils getUserInfo];
    
//    self.scrollView.contentSize = CGSizeMake(80.0, 550.0);
    
    self.lblOrderStatus.text = [self.order objectForKey:@"status_msg"];
    self.lblOrderTotal.text = [AppUtils makeMoneyString:[self.order objectForKey:@"goods_price"]];
    self.lblFirstPayment.text = [AppUtils makeMoneyString:[[self.order objectForKey:@"goods_type"] objectForKey:@"first_price"]];
    self.lblMonthPayment.text = [AppUtils makeMoneyString:[[self.order objectForKey:@"goods_type"] objectForKey:@"monthly_price"]];
    self.lblPeriods.text = [[self.order objectForKey:@"goods_type"] objectForKey:@"periods"];
    [self.imgGoods sd_setImageWithURL:[NSURL URLWithString:[self.order objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    self.lblGoodsName.text = [self.order objectForKey:@"goods_name"];
    self.lblOrderNo.text = [NSString stringWithFormat:@"订单号：%@", [self.order objectForKey:@"business_no"]];
    self.lblOrderDate.text = [NSString stringWithFormat:@"下单时间：%@", [self.order objectForKey:@"time"]];
    self.lblOrderTotal.text = [self.order objectForKey:@"goods_price"];
    self.lblOrderTotal.text = [self.order objectForKey:@"goods_price"];
    self.lblOrderTotal.text = [self.order objectForKey:@"goods_price"];
    
    [self getUserAddressFromAPI];
    [self getOrderTrackFromAPI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
    [self getOrderGoodsRateFromAPI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [MobClick endLogPageView:TAG];
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doRateAction:(id)sender {
    OrderEvaluateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderEvaluateIdentifier"];
    vc.order = self.order;
    [AppUtils pushPage:self targetVC:vc];
}
@end
