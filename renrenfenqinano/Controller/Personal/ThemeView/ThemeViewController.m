//
//  ThemeViewController.m
//  renrenfenqi
//
//  Created by DY on 15/1/9.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "ThemeViewController.h"
#import "CommonTools.h"
#import "ShareView.h"
#import "CommentViewController.h"
#import "AppDelegate.h"
#import "UserLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "GoodsDetailSpecViewController.h"
#import "OrderWebViewController.h"

@interface ThemeViewController ()
{
    UIStoryboard *_mainStoryboard;
    NSDictionary *_userIfo;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UIView *menuView;

@property (strong, nonatomic) UIButton *praiseBtn;
@property (strong, nonatomic) UIButton *shareBtn;
@property (strong, nonatomic) UIButton *commentBtn;

//@property (strong, nonatomic) WKWebView *test;

@end

@implementation ThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    [self initData];
    // 创建导航页面
    [self createTopView];
    // 创建主内容界面
    [self createcontentView];
    // 创建功能按钮界面，点赞，分享，评论
    [self createMenuView];
    
    [self getActivityInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 初始化参数
- (void)initData {
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _userIfo = [AppUtils getUserInfo];
}

#pragma mark UI创建

// 创建top导航页面
- (void)createTopView {
    self.topView = [CommonTools generateTopBarWiwhOnlyBackButton:self title:self.titleString action:@selector(back:)];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
}

// 创建UIWebView页面，显示具体内容
- (void)createcontentView {
    self.contentWebView = [[UIWebView alloc] init];
    self.contentWebView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, _MainScreen_Width, _MainScreenFrame.size.height - (self.topView.frame.origin.y + self.topView.frame.size.height));
    self.contentWebView.scrollView.bounces = NO;
    [self.view addSubview:self.contentWebView];
    
    self.contentWebView.delegate = self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.url]]];
    [self.contentWebView loadRequest:request];

}

// 创建底部功能按钮界面，点赞，分享，评论
- (void)createMenuView {
    
    if (IOS8_OR_LATER) {
        self.menuView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    }else{
        self.menuView = [[UIView alloc] init];
        self.menuView.alpha = 0.8;
    }
    
    self.menuView.frame = CGRectMake(0, _MainScreenFrame.size.height - 48, _MainScreenFrame.size.width, 48);
    [self.view addSubview:self.menuView];
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 0, self.menuView.frame.size.width, 0.5f);
    line.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.menuView addSubview:line];
    
    float buttonWidth = (self.menuView.frame.size.width-1) / 3;
    float buttonHeight = self.menuView.frame.size.height;
    
    self.praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseBtn.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    [self.praiseBtn setImage:[UIImage imageNamed:@"graphicdetails_body_praise_n@2x.png"] forState:UIControlStateNormal];
    [self.praiseBtn setTitleColor:UIColorFromRGB(0x939393) forState:UIControlStateNormal];
    self.praiseBtn.titleLabel.font = GENERAL_FONT15;
    [self.praiseBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    self.praiseBtn.tag = MenuBtnTag_Praise;
    [self.praiseBtn addTarget:self action:@selector(menuResponse:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.praiseBtn];
    
    UIView *line1 = [[UIView alloc] init];
    line1.frame = CGRectMake(self.praiseBtn.frame.origin.x + self.praiseBtn.frame.size.width, 0, 0.5f, buttonHeight);
    line1.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.menuView addSubview:line1];
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareBtn.frame = CGRectMake(line1.frame.origin.x + line1.frame.size.width, 0, buttonWidth, buttonHeight);
    [self.shareBtn setImage:[UIImage imageNamed:@"graphicdetails_body_share_n@2x.png"] forState:UIControlStateNormal];
    self.shareBtn.tag = MenuBtnTag_Share;
    [self.shareBtn addTarget:self action:@selector(menuResponse:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.shareBtn];
    
    UIView *line2 = [[UIView alloc] init];
    line2.frame = CGRectMake(self.shareBtn.frame.origin.x + self.shareBtn.frame.size.width, 0, 0.5f, buttonHeight);
    line2.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.menuView addSubview:line2];
    
    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentBtn.frame = CGRectMake(line2.frame.origin.x + line2.frame.size.width, 0, buttonWidth, buttonHeight);
    [self.commentBtn setImage:[UIImage imageNamed:@"graphicdetails_body_appraisal_n@2x.png"] forState:UIControlStateNormal];
    [self.commentBtn setTitleColor:UIColorFromRGB(0x939393) forState:UIControlStateNormal];
    [self.commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    self.commentBtn.titleLabel.font = GENERAL_FONT15;
    self.commentBtn.tag = MenuBtnTag_Comment;
    [self.commentBtn addTarget:self action:@selector(menuResponse:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.commentBtn];
}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)LoginVc {
    UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [ThemeViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
    
    [AppUtils showLoadInfo:@"请先登录账号"];
}

// 底部按钮响应函数处理
- (void)menuResponse:(UIButton *)sender {
    switch (sender.tag) {
        case MenuBtnTag_Praise:
            NSLog(@"点击点赞按钮");
            [self praiseAction];
            break;
            
        case MenuBtnTag_Share:
            NSLog(@"点击分享按钮");
            [self shareAction];
            break;
            
        case MenuBtnTag_Comment:
            NSLog(@"点击评论按钮");
            [self commentaction];
            break;
            
        default:
            break;
    }
}

// 点击点赞
- (void)praiseAction {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        [self requestAddPraiseCount];
    }else{
        [self LoginVc];
    }
}

// 点击分享
- (void)shareAction {
    ShareView *view = [[ShareView alloc] initWithFrame:self.view.frame];
    view.thumbnail = self.thumbnail;
    view.url = self.url;
    view.titleString = self.titleString;
    [view showDialog:YES];
}

// 点击评论
- (void)commentaction {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        CommentViewController *vc = [[CommentViewController alloc] init];
        vc.activityID = self.activityID;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        [self LoginVc];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requsestString = [[request URL] absoluteString];
    NSString *protocol = @"renrenfenqi://";
    if ([requsestString hasPrefix:protocol]) {
        NSString *requestContent = [requsestString substringFromIndex:[protocol length]];
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if ([[vals objectAtIndex:0] isEqualToString:@"goods"]) {
            NSLog(@"商品详情:%@", vals);
            NSString *tempStr = [NSString stringWithFormat:@"%@", [vals objectAtIndex:1]];
            NSLog(@"%d", (int)tempStr.length);
            OrderWebViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
            vc.goodsID = tempStr;
            [AppUtils pushPage:self targetVC:vc];
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
    [self respondJSUserIfo];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [AppUtils showLoadInfo:@"网络异常，请求超时"];
}

#pragma mark 数据处理

// 获取活动主题的赞和评论数量
- (void)getActivityInfo {
    NSString *userId = [[_userIfo objectForKey:@"info"] objectForKey:@"uid"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId,
                                 @"ac_id":self.activityID};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, GET_ACTIVITY_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleActivityInfo:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleActivityInfo:(NSDictionary *)dic {
    NSString *commentCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"appraise_count"]];
    NSString *praiseCount = [NSString stringWithFormat:@"%@", [dic objectForKey:@"laud_count"]];
    NSString *laudStatus = [NSString stringWithFormat:@"%@", [dic objectForKey:@"laud_status"]];
    praiseCount = [AppUtils filterNull:praiseCount];
    commentCount = [AppUtils filterNull:commentCount];
    if ([AppUtils isNullStr:laudStatus]) {
        laudStatus = @"0";
    }
    
    if ([laudStatus boolValue]) {
        [self.praiseBtn setImage:[UIImage imageNamed:@"graphicdetails_body_praise_h@2x.png"] forState:UIControlStateNormal];
    }
    [self.praiseBtn setTitle:praiseCount forState:UIControlStateNormal];
    [self.commentBtn setTitle:commentCount forState:UIControlStateNormal];
}

// 点赞接口
- (void)requestAddPraiseCount {
    NSString *userId = [[_userIfo objectForKey:@"info"] objectForKey:@"uid"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId,
                                 @"ac_id":self.activityID};
    
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, POST_ADD_PRAISECOUNT] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            NSString *newPraiseCount = [NSString stringWithFormat:@"%@", [jsonData objectForKey:@"laud"]];
            [self.praiseBtn setTitle:newPraiseCount forState:UIControlStateNormal];
            [self.praiseBtn setImage:[UIImage imageNamed:@"graphicdetails_body_praise_h@2x.png"] forState:UIControlStateNormal];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

// 反馈登录信息给JS
- (void)respondJSUserIfo {
    [self.contentWebView stringByEvaluatingJavaScriptFromString:@"_client.user_login('jjjh')"];
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
