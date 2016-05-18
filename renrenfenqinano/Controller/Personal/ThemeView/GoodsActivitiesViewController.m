//
//  GoodsActivitiesViewController.m
//  renrenfenqi
//
//  Created by DY on 15/1/15.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "GoodsActivitiesViewController.h"
#import "CommonTools.h"
#import "ShareView.h"
#import "GoodsDetailSpecViewController.h"
#import "UIImageView+WebCache.h"
#import "UserLoginViewController.h"
#import "OrderWebViewController.h"

@interface GoodsActivitiesViewController ()
{
    UIStoryboard *_mainStoryboard;
    NSDictionary *_accountInfo;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIWebView *contentWebView;

@end

@implementation GoodsActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 创建导航页面
    [self createTopView];
    // 创建主内容界面
    [self createcontentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendLoginInfoToActivity
{
    if ([AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
        [self.contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"_client.user_login('{\"client\":\"ios\",\"isLogin\":true,\"uid\":%@,\"token\":\"%@\"}')", [[_accountInfo objectForKey:@"info"] objectForKey:@"uid"], [_accountInfo objectForKey:@"token"]]];
    }
    else {
        [self.contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"_client.user_login('{\"client\":\"ios\",\"isLogin\":false}')"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
    _accountInfo = [AppUtils getUserInfo];
    [self sendLoginInfoToActivity];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [MobClick endLogPageView:TAG];
}

#pragma mark UI创建

// 创建top导航页面
- (void)createTopView {
    self.topView = [CommonTools generateTopBarWiwhOnlyBackButton:self title:self.titleString action:@selector(back:)];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"activity_body_star_n@2x.png"] forState:UIControlStateNormal];
    shareBtn.frame = CGRectMake(self.view.frame.size.width - 44, 20, 44, 44);
    [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareBtn];
}

// 创建UIWebView页面，显示具体内容
- (void)createcontentView {
    self.contentWebView = [[UIWebView alloc] init];
    self.contentWebView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, _MainScreenFrame.size.width, _MainScreenFrame.size.height - (self.topView.frame.origin.y + self.topView.frame.size.height));
    self.contentWebView.scrollView.bounces = NO;
    [self.view addSubview:self.contentWebView];
    
    for (UIView *_aView in [self.contentWebView subviews]){
        if ([_aView isKindOfClass:[UIScrollView class]]){
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO]; //右侧的滚动条
//            for (UIView *_inScrollview in _aView.subviews){
//                if ([_inScrollview isKindOfClass:[UIImageView class]]){
//                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
//                }
//            }
        }
    }
    
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"HHmmss";
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    NSString *url = [NSString stringWithFormat:@"%@?client=%@&versiondate=%@",self.url, URLKEY_IOS,locationString];
    self.contentWebView.delegate = self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]];
    [self.contentWebView loadRequest:request];
}

- (void)doLogin {
    UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [GoodsActivitiesViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requsestString = [[request URL] absoluteString];
    if ([requsestString hasPrefix:URL_PROTOCOL]) {
        NSString *requestContent = [requsestString substringFromIndex:[URL_PROTOCOL length]];
        MyLog(requestContent);
        
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if ([[vals objectAtIndex:0] isEqualToString:@"goods"]) {
            NSString *tempStr = [NSString stringWithFormat:@"%@", [vals objectAtIndex:1]];
            if ([AppUtils isNullStr:tempStr]) {
                return NO;
            }else{
                OrderWebViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
                vc.goodsID = tempStr;
                [AppUtils pushPage:self targetVC:vc];
            }
        }
        
        if ([requestContent isEqualToString:@"user/login"]) {
            [self doLogin];
        }
        
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [AppUtils showLoadIng];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [AppUtils hideLoadIng];
    
    [self sendLoginInfoToActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [AppUtils showLoadInfo:@"网络异常，请求超时"];
}

// 反馈登录信息给JS
//- (void)respondJSUserIfo {
//    [self.contentWebView stringByEvaluatingJavaScriptFromString:@"_client.user_login('jjjh')"];
//}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)shareAction:(UIButton *)sender {
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"HHmmss";
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    ShareView *view = [[ShareView alloc] initWithFrame:self.view.frame];
    view.titleString = self.titleString;
    view.thumbnail = nil;// 当前版本用默认图片  thumbnailUrl可以不用
    view.url = [NSString stringWithFormat:@"%@?client=%@&versiondate=%@",self.url, SHARE_URL_KEY, locationString];
    [view showDialog:YES];
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
