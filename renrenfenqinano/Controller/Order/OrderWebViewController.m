//
//  OrderWebViewController.m
//  renrenfenqi
//
//  Created by coco on 15-5-6.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "OrderWebViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#import "UserLoginViewController.h"
#import "GoodsDetailSpecViewController.h"
#import "GoodsDetailsConfigViewController.h"
#import "GoodsRatesViewController.h"
#import "OrderConfirmViewController.h"

@interface OrderWebViewController () {
    NSDictionary *_accountInfo;
    NSDictionary *_goodsDetail;
    
    Class _pushedClass;     //存储 push到哪个VC
}

@end

@implementation OrderWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    self.webView.delegate = self;
    [self loadWebView];
}

- (void)loadWebView {
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *htmlPath = [documentsDirectory stringByAppendingPathComponent:@"/source/views/goods/goodsdetail.html"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    
    //TODO to delete
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    MyLog(@"files array %@", filePathsArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doLogin
{
    UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [GoodsDetailSpecViewController class];
    _pushedClass = [UserLoginViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
    _accountInfo = [AppUtils getUserInfo];
    if (_pushedClass && (_pushedClass == [UserLoginViewController class])) {
        [self getGoodsDetailFromAPI];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)getGoodsRatesFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    [AppUtils showLoadIng];
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", 1]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, RATELIST] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        [AppUtils hideLoadIng];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"h5.userAssess(%@)", operation.responseString]];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
        if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
            [self doLogin];
        }
        else
        {
            [self getGoodsDetailFromAPI];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils hideLoadIng];
    }];
}

- (void)loadDataToWeb:(AFHTTPRequestOperation *)operation
{

    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"h5.client(%@)", @"'ios'"]];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"h5.pageInit(%@)", operation.responseString]];
}

- (void)getGoodsDetailFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL_SPEC_LOGIN] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [AppUtils hideLoadIng];
        
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _goodsDetail = [jsonData objectForKey:@"data"];
            
            [self loadDataToWeb:operation];
        } else if ([@"-1" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showInfo:STR_LOGIN_TIMEOUT];
            [self doLogin];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils hideLoadIng];
    }];
}

//- (void)getUserCreditFromAPIAndUpdateUI
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
//    
//    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
//                                 @"token":[_accountInfo objectForKey:@"token"]};
//    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL_SPEC_LOGIN] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
//    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
//    }];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UIWebViewDelegate

- (NSString *)getAction:(NSString *)actionStr {
    NSString *action;
    
    NSArray *arr = [actionStr componentsSeparatedByString:@"("];
    if (arr.count > 0 && [actionStr hasPrefix:URL_PROTOCOL]) {
        NSArray *arrStr = [arr[0] componentsSeparatedByString:@"/"];
        
        if (arrStr.count > 3) {
            action = arrStr[3];
        }
    }
    
    return action;
}

- (NSArray *)getOrderParams:(NSString *)actionStr {
    NSArray *params;
    
    NSArray *arr = [actionStr componentsSeparatedByString:@"("];
    if (arr.count > 1 && [actionStr hasPrefix:URL_PROTOCOL]) {
        NSArray *arrStr = [arr[1] componentsSeparatedByString:@")"];
        if (arrStr.count > 0) {
            params = [arrStr[0] componentsSeparatedByString:@"--"];
        }
    }
    
    return params;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requsestString = [[request URL] absoluteString];
    NSString *actionStr = [requsestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *action = [self getAction:actionStr];
    
    if ([actionStr hasPrefix:URL_PROTOCOL]) {
        if ([action isEqualToString:@"goGoodsDetail"]) {
            GoodsDetailsConfigViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailsConfigIdentifier"];
            vc.htmlStr = [_goodsDetail objectForKey:@"description"];
            vc.isDetail = YES;
            _pushedClass = [GoodsDetailsConfigViewController class];
            [AppUtils pushPage:self targetVC:vc];
        } else if ([action isEqualToString:@"goGoodsConfiguration"]) {
            GoodsDetailsConfigViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailsConfigIdentifier"];
            vc.htmlStr = [_goodsDetail objectForKey:@"configure"];
            vc.isDetail = NO;
            _pushedClass = [GoodsDetailsConfigViewController class];
            [AppUtils pushPage:self targetVC:vc];
        } else if ([action isEqualToString:@"goGoodsComments"]) {
            GoodsRatesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsRatesIdentifier"];
            vc.goodsID = self.goodsID;
            _pushedClass = [GoodsRatesViewController class];
            [AppUtils pushPage:self targetVC:vc];
        } else if ([action isEqualToString:@"goBack"]) {
            [AppUtils goBack:self];
        } else if ([action isEqualToString:@"goGoodsVerify"]) {
            NSArray *orderParam = [self getOrderParams:actionStr];
            if (orderParam.count > 1) {
                OrderConfirmViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmIdentifier"];
                
                MyLog(@"order params = %@", orderParam);
                NSDictionary *orderDict1 = [orderParam[0] objectFromJSONString];
                NSDictionary *orderDict2 = [orderParam[1] objectFromJSONString];
                vc.goodsID = [orderDict1 objectForKey:@"goods_id"];
                vc.goodsName = [orderDict2 objectForKey:@"goods_name"];
                vc.goodsDetail = _goodsDetail;
                vc.goodsPrice = [[orderDict2 objectForKey:@"goods_price"] floatValue];
                vc.firstPaymentRatio = [[orderDict1 objectForKey:@"first_pay"] floatValue] * 0.01;
                vc.fenqiNum = [[orderDict1 objectForKey:@"periods"] intValue];
                vc.orderParams1 = [orderParam[0] objectFromJSONString];
                vc.orderParams2 = [orderParam[1] objectFromJSONString];
                vc.jobPrice = [[orderDict2 objectForKey:@"job_price"] floatValue];
                vc.jobType = self.jobType;
                _pushedClass = [OrderConfirmViewController class];
                [AppUtils pushPage:self targetVC:vc];
            }
            
        }
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"renrenAct.goGoodsDetail('7')"]];
    
//    [self performSelector:@selector(getGoodsRatesFromAPI) withObject:self afterDelay:1.0];
    [self getGoodsRatesFromAPI];
}

@end
