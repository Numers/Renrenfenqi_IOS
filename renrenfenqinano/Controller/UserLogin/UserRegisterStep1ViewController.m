//
//  UserRegisterStep1ViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "UserRegisterStep1ViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UserRegisterStep2ViewController.h"
#import "AppDelegate.h"
#import "CommonWebViewController.h"

@interface UserRegisterStep1ViewController ()

@end

@implementation UserRegisterStep1ViewController

- (void)doGetCaptcha:(NSString *)thePhone
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:thePhone forKey:@"phone"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_CAPTCHA_REG] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.btnNext.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"您已获取验证码！"];
            
            UserRegisterStep2ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserRegisterStep2Identifier"];
            vc.phone = thePhone;
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        self.btnNext.enabled = YES;
    }];
}

-(void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isAgree = NO;
    
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doAgreeAction:(id)sender {
    
    self.isAgree = !self.isAgree;
    if (self.isAgree) {
        [self.btnAgree setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_h"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAgree setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_n"] forState:UIControlStateNormal];
    }
}

- (IBAction)doNextAction:(id)sender {
    
    //校验用户输入信息是否正确
    if (!self.isAgree) {
        [AppUtils showInfo:@"请先同意注册协议"];
        return;
    }
    
    NSString *thePhone = [AppUtils trimWhite:_txtPhone.text];
    if ([AppUtils isNullStr:thePhone]) {
        [AppUtils showInfo:@"手机号码不能为空"];
        return;
    }
    if (![AppUtils isMobileNumber:thePhone]) {
        [AppUtils showInfo:@"手机号码格式不正确"];
        return;
    }
    
    [self doGetCaptcha:thePhone];
}

- (IBAction)doAgreementAction:(id)sender {
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CommonWebViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_LOGIN_UP;
    vc.titleString = @"仁仁分期注册协议";
    vc.hidesBottomBarWhenPushed = YES;
    [AppUtils pushPage:self targetVC:vc];
}
@end
