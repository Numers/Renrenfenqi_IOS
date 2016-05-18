//
//  UserRegisterStep3ViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "UserRegisterStep3ViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UserLoginViewController.h"
#import "ImprovePersonalInfoViewController.h"

@interface UserRegisterStep3ViewController ()
{
    UIStoryboard *_secondStorybord;
}

@end

@implementation UserRegisterStep3ViewController

- (void)userResetPassword:(NSString *)thePhone captcha:(NSString *)theCaptcha pwd:(NSString *)thePassword
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:thePhone forKey:@"phone"];
    [parameters setValue:theCaptcha forKey:@"captcha"];
    [parameters setValue:thePassword forKey:@"pwd"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_RESETPASSWORD] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.btnOK.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"重设密码成功！"];
            [self goToLogin];
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        self.btnOK.enabled = YES;
    }];
}

- (void)goToLogin
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *theVC in allViewControllers) {
        if ([theVC isKindOfClass:[UserLoginViewController class]]) {
//            [self.navigationController popToViewController:theVC animated:NO];
            [AppUtils popToPage:self targetVC:theVC];
            break;
        }
    }
}

- (void)userReg:(NSString *)thePhone captcha:(NSString *)theCaptcha pwd:(NSString *)thePassword
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:thePhone forKey:@"phone"];
    [parameters setValue:theCaptcha forKey:@"captcha"];
    [parameters setValue:thePassword forKey:@"pwd"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_REG] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.btnOK.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"您已成功注册！"];
            [persistentDefaults setObject:@"yes" forKey:@"WriteJobSetting"];
            [persistentDefaults setObject:[NSString stringWithFormat:@"%@|%@", thePhone, thePassword] forKey:@"RegInfo"];
            [self goToLogin];
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        self.btnOK.enabled = YES;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    persistentDefaults = [NSUserDefaults standardUserDefaults];
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

- (IBAction)doSetPassword:(id)sender {
    NSString *thePassword = [AppUtils trimWhite:self.txtPassword.text];
    NSString *thePasswordAgain = [AppUtils trimWhite:self.txtPasswordAgain.text];
    if ([AppUtils isNullStr:thePassword]) {
        [AppUtils showInfo:@"密码不能为空"];
        return;
    }
    if (thePassword.length < 6) {
        [AppUtils showInfo:@"密码长度过短(小于6个字符)"];
        return;
    }
    if (![thePassword isEqualToString:thePasswordAgain]) {
        [AppUtils showInfo:@"两次密码输入不一致"];
        return;
    }
    
    if (self.isForgetPassword) {
        [self userResetPassword:self.phone captcha:self.captcha pwd:thePassword];
    }
    else
    {
        [self userReg:self.phone captcha:self.captcha pwd:thePassword];
    }
    
}
@end
