//
//  RFPartJobViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFPartJobViewController.h"
#import "RFSelectCityViewController.h"
#import "AppUtils.h"
#import "GlobalVar.h"
#import "JSONKit.h"
#import "RFCity.h"
#import "RFLocationHelper.h"
#import "RFPartJobWebViewJsBridge.h"
#import "UserLoginViewController.h"
//#import "LocalSubstitutionCache.h"

static NSString *CurrentLoadURLMark = @"CurrentLoadURLMark";
static NSString *CurrentApplyJobID = @"CurrentApplyJobID";
static NSString *CurrentClientID = @"CurrentClientID";
@interface RFPartJobViewController ()<UIWebViewDelegate,RFPartJobDelegate,RFPartJobViewDelegate>
{
    UIActivityIndicatorView *activityView;
    RFPartJobWebViewJsBridge *bridge;
    RFCity *currentSelectCity;
    
    NSString *currentLoadURL;
    NSString *applyJobId;
    BOOL isLock;
}
@property(nonatomic, strong) UIWebView *webView;
@end

@implementation RFPartJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    LocalSubstitutionCache *urlCache = [[LocalSubstitutionCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
//                                                                                 diskCapacity:200 * 1024 * 1024
//                                                                                     diskPath:nil
//                                                                                    cacheTime:0];
//    [LocalSubstitutionCache setSharedURLCache:urlCache];
    
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy =
    NSHTTPCookieAcceptPolicyAlways;

    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_webView];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setOpaque:NO];
    [activityView setCenter:_webView.center];
    [_webView addSubview:activityView];
    bridge = [RFPartJobWebViewJsBridge bridgeForWebView:_webView webViewDelegate:self];
    bridge.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [self loadRequest];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    LocalSubstitutionCache *urlCache = (LocalSubstitutionCache *)[NSURLCache sharedURLCache];
//    [urlCache removeAllCachedResponses];
}

-(NSString *)currentLoadURLFromUserDefaults
{
    NSString *currentURL = nil;
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *key = [NSString stringWithFormat:@"%@_%@",uid,CurrentLoadURLMark];
        currentURL = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    
    if (!currentURL) {
//        if (currentLoadURL) {
//            if (!([currentLoadURL containsString:@"uid"] && [currentLoadURL containsString:@"token"])){
//                currentURL = currentLoadURL;
//            }
//        }
        if (currentSelectCity) {
            NSDictionary *locationInfo = [[RFLocationHelper defaultHelper] returnLocaitonInfo];
            NSString *encodeCityStr = [currentSelectCity.cityName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            currentURL = [NSString stringWithFormat:@"%@/#/job/list/%ld/1?client=%@&cityID=%ld&cityName=%@&lat=%@&lng=%@",BaseJobH5URL,(long)currentSelectCity.cityId,[locationInfo objectForKey:@"client"],(long)currentSelectCity.cityId,encodeCityStr,[[locationInfo objectForKey:@"location"] objectForKey:@"lat"],[[locationInfo objectForKey:@"location"] objectForKey:@"lng"]];
        }
        
        if (!currentURL){
            NSDictionary *locationInfo = [[RFLocationHelper defaultHelper] returnLocaitonInfo];
            NSString *encodeCityStr = [[locationInfo objectForKey:@"cityName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            currentURL = [NSString stringWithFormat:@"%@/#/job/list/%@/1?client=%@&cityID=%@&cityName=%@&lat=%@&lng=%@",BaseJobH5URL,[locationInfo objectForKey:@"cityID"],[locationInfo objectForKey:@"client"],[locationInfo objectForKey:@"cityID"],encodeCityStr,[[locationInfo objectForKey:@"location"] objectForKey:@"lat"],[[locationInfo objectForKey:@"location"] objectForKey:@"lng"]];
        }
    }
    return currentURL;
}

-(void)loadRequest
{
    currentLoadURL = [self currentLoadURLFromUserDefaults];
    //对url如果存在clickId,那么把clickId之后的问号改为&
    NSRange rangeClickId;
    rangeClickId = [currentLoadURL rangeOfString:@"clickId="];
    if (rangeClickId.location && rangeClickId.length == 8) {
        NSRange repalceRange;
        repalceRange.location = rangeClickId.location + 8;
        repalceRange.length = currentLoadURL.length - rangeClickId.location - 8;
        currentLoadURL = [currentLoadURL stringByReplacingOccurrencesOfString:@"?" withString:@"&" options:NSCaseInsensitiveSearch range:repalceRange];
    }
    
    ///////////////////////////////////////////////////////
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSLog(@"%@",[[_webView.request URL] absoluteString]);
        NSString *url;
        if ([currentLoadURL containsString:@"uid"] && [currentLoadURL containsString:@"token"]) {
            url = currentLoadURL;
        }else{
            NSString *token = [loginInfo objectForKey:@"token"];
            url = [NSString stringWithFormat:@"%@&uid=%@&token=%@",currentLoadURL,uid,token];
        }
        
        NSString *loadURL;
        NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",uid,CurrentClientID]];
        if (clientId) {
            loadURL = [NSString stringWithFormat:@"%@&clientId=%@",url,clientId];
        }else{
            loadURL = url;
        }
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loadURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut]];
    }else{
        NSLog(@"%@",[[_webView.request URL] absoluteString]);
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentLoadURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut]];
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

#pragma -mark  WebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *absoluteString = [[request URL] absoluteString];
    if ([absoluteString hasPrefix:@"tel:"]) {
        return YES;
    }
    if (![absoluteString hasPrefix:@"http"]) {
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityView setOpaque:YES];
    [activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ((title != nil) && (title.length > 0)) {
        [self.navigationItem setTitle:title];
    }
    [activityView setOpaque:NO];
    [activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityView setOpaque:NO];
    [activityView stopAnimating];
    [AppUtils showInfo:@"网页加载失败"];
}

#pragma -mark RFPartJobDelegate
-(NSString *)getJsonLocationInfo
{
    NSString *jsonStr = nil;
    NSDictionary *locationInfo = [[RFLocationHelper defaultHelper] returnLocaitonInfo];
    if (currentSelectCity) {
        NSDictionary *locationOtherCityInfo = [NSDictionary dictionaryWithObjectsAndKeys:[locationInfo objectForKey:@"client"],@"client",[locationInfo objectForKey:@"location"],@"location",[NSString stringWithFormat:@"%ld",(long)currentSelectCity.cityId],@"cityID",currentSelectCity.cityName,@"cityName", nil];
        jsonStr = [locationOtherCityInfo JSONString];
    }else{
        if (locationInfo) {
            jsonStr = [locationInfo JSONString];
        }else{
            jsonStr = nil;
        }
    }
    return jsonStr;
}

-(NSString *)getJsonLoginInfo
{
    NSString *jsonStr = nil;
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
//        NSString *token = [loginInfo objectForKey:@"token"];
//        NSString *url = [NSString stringWithFormat:@"%@&uid=%@&token=%@",currentLoadURL,uid,token];
//        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TimeOut]];
    }else{
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserLoginViewController *loginVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        [AppUtils pushPageFromBottomToTop:self targetVC:loginVC];
    }
    return jsonStr;
}

-(void)pushToSelectCityView
{
    RFSelectCityViewController *rfSelectCityVC = [[RFSelectCityViewController alloc] initWithGpsCity:[[RFLocationHelper defaultHelper] returnGPSCity]];
    rfSelectCityVC.delegate = self;
    rfSelectCityVC.hidesBottomBarWhenPushed = YES;
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:rfSelectCityVC animated:YES];
}

-(void)returnCurrentUrl:(NSString *)url
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]){
        if ([url containsString:@"uid"] && [url containsString:@"token"]) {
            currentLoadURL = url;
        }else{
            currentLoadURL = [NSString stringWithFormat:@"%@?uid=%@&token=%@",url,uid,[loginInfo objectForKey:@"token"]];
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentLoadURL]]];
        }
    }else{
        currentLoadURL = url;
    }
}

-(void)applyJobID:(NSString *)jobId
{
    applyJobId = jobId;
}

-(void)saveClientID:(NSString *)clientId
{
    if (clientId) {
        NSDictionary *loginInfo = [AppUtils getUserInfo];
        NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
        if ([AppUtils isLogined:uid]) {
            NSString *key = [NSString stringWithFormat:@"%@_%@",uid,CurrentClientID];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:clientId forKey:key];
            [userDefaults synchronize];
        }
    }
}

-(void)lockURL:(NSString *)url
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *key = [NSString stringWithFormat:@"%@_%@",uid,CurrentLoadURLMark];
        NSString *applyJobIdKey = [NSString stringWithFormat:@"%@_%@",uid,CurrentApplyJobID];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:url forKey:key];
        if (applyJobId) {
            [userDefaults setObject:applyJobId forKey:applyJobIdKey];
        }
        [userDefaults synchronize];
        currentLoadURL = url;
    }
}

-(void)unLock
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *key = [NSString stringWithFormat:@"%@_%@",uid,CurrentLoadURLMark];
        NSString *keyJobID = [NSString stringWithFormat:@"%@_%@",uid,CurrentApplyJobID];
        NSString *keyClientId = [NSString stringWithFormat:@"%@_%@",uid,CurrentClientID];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:key];
        [userDefaults removeObjectForKey:keyClientId];
        [userDefaults removeObjectForKey:keyJobID];
    }
}

-(void)commentCompletely
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *key = [NSString stringWithFormat:@"%@_%@",uid,CurrentLoadURLMark];
        NSString *keyJobID = [NSString stringWithFormat:@"%@_%@",uid,CurrentApplyJobID];
        NSString *keyClientId = [NSString stringWithFormat:@"%@_%@",uid,CurrentClientID];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:key];
        [userDefaults removeObjectForKey:keyClientId];
        [userDefaults removeObjectForKey:keyJobID];
        [self loadRequest];
    }
}

#pragma -mark SelectCityDelegate
-(void)selectCity:(RFCity *)selectCity
{
    currentSelectCity = selectCity;
}
@end
