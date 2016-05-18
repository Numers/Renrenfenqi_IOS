//
//  UserRegisterStep2ViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "UserRegisterStep2ViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UserRegisterStep3ViewController.h"

@interface UserRegisterStep2ViewController ()
{
    NSTimer *_timerDown;
    
    int _counter;
}

@end

@implementation UserRegisterStep2ViewController

-(void)countDown
{
    MyLog(@"count down %d", _counter);
    if (_counter > 0) {
        if (_counter == 60) {
            self.btnResend.enabled = NO;
        }
        else if (_counter == 1)
        {
            self.btnResend.enabled = YES;
        }
        
        _counter--;
        
//        self.btnResend.titleLabel.text = [NSString stringWithFormat:@"重发(%d)", _counter];
        [UIView setAnimationsEnabled:NO];
        [self.btnResend setTitle:[NSString stringWithFormat:@"重发(%d)", _counter] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)doGetForgetPasswordCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.phone forKey:@"phone"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_CAPTCHA_FORGET] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _counter = 60;
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)doGetAccountRegCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.phone forKey:@"phone"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_CAPTCHA_REG] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _counter = 60;
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)captchaVerify:(NSString *)thePhone captcha:(NSString *)theCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:thePhone forKey:@"phone"];
    [parameters setValue:theCaptcha forKey:@"captcha"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_CAPTCHA_VERIFY] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.btnNext.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"成功校验验证码！"];
            
            UserRegisterStep3ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserRegisterStep3Identifier"];
            vc.phone = thePhone;
            vc.captcha = theCaptcha;
            vc.isForgetPassword = self.isForgetPassword;
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        self.btnNext.enabled = YES;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblTip.text = [NSString stringWithFormat:@"请输入手机号%@收到的短信验证码", self.phone];
    
    _counter = 60;
    _timerDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_timerDown) {
        [_timerDown invalidate];
        _timerDown = nil;
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doResendAction:(id)sender {
    if (self.isForgetPassword) {
        [self doGetForgetPasswordCaptcha];
    }
    else
    {
        [self doGetAccountRegCaptcha];
    }
}

- (IBAction)doNextAction:(id)sender {
    NSString *theCaptcha = [AppUtils trimWhite:self.txtCaptcha.text];
    if ([AppUtils isNullStr:theCaptcha]) {
        [AppUtils showInfo:@"验证码不能为空"];
        return;
    }
    
    [self captchaVerify:self.phone captcha:theCaptcha];
}
@end
