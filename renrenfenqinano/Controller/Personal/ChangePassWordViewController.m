//
//  ChangePassWordViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/3.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ChangePassWordViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

@interface ChangePassWordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITextField *oldPsdTextField;
@property (weak, nonatomic) IBOutlet UITextField *mynewPsdTextField;
@property (weak, nonatomic) IBOutlet UITextField *againTextField;

@property (weak, nonatomic) IBOutlet UILabel *tips1Label;
@property (weak, nonatomic) IBOutlet UILabel *tips2Label;
@property (weak, nonatomic) IBOutlet UILabel *tips3Label;


@end

@implementation ChangePassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tips1Label.hidden = YES;
    self.tips2Label.hidden = YES;
    self.tips3Label.hidden = YES;
    
    self.oldPsdTextField.delegate = self;
    self.oldPsdTextField.secureTextEntry = YES;
    self.oldPsdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.oldPsdTextField.returnKeyType = UIReturnKeyNext;
    
    self.mynewPsdTextField.delegate = self;
    self.mynewPsdTextField.secureTextEntry = YES;
    self.mynewPsdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.mynewPsdTextField.returnKeyType = UIReturnKeyNext;
    
    self.againTextField.delegate = self;
    self.againTextField.secureTextEntry = YES;
    self.againTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.againTextField.returnKeyType = UIReturnKeyDone;
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

#pragma mark 数据处理

- (void)postChangePsd:(NSString *)oldPsd newPassword:(NSString *)newpsd
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:oldPsd forKey:@"old"];
    [parameters setValue:newpsd forKey:@"new"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, CHANGE_PASSWORD] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.commitBtn.enabled = YES;
        
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            [AppUtils showLoadInfo:@"修改密码成功请重新登录"];
            [app.store clearTable:USER_TABLE];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];

            [self back:nil];
            
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        self.commitBtn.enabled = YES;
    }];
}

#pragma mark TextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.oldPsdTextField) {
        if ([self judgePsdRule:self.oldPsdTextField.text]) {
            self.tips1Label.hidden = YES;
        }else{
            self.tips1Label.hidden = NO;
        }
    }else if (textField == self.mynewPsdTextField){
        if ([self judgePsdRule:self.mynewPsdTextField.text]) {
            self.tips2Label.hidden = YES;
        }else{
            self.tips2Label.hidden = NO;
        }
    }else if (textField == self.againTextField){
        if ([self judgePsdRule:self.againTextField.text] && [self.mynewPsdTextField.text isEqualToString:self.againTextField.text]) {
            self.tips3Label.hidden = YES;
        }else if (![self.mynewPsdTextField.text isEqualToString:self.againTextField.text]){
            self.tips3Label.hidden = NO;
            self.tips3Label.text = @"2次输入不一致";
        }else{
            self.tips3Label.hidden = NO;
            self.tips3Label.text = @"密码不符合规则请重新输入";
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.oldPsdTextField) {
        [self.oldPsdTextField resignFirstResponder];
        [self.mynewPsdTextField becomeFirstResponder];
        if ([self judgePsdRule:self.oldPsdTextField.text]) {
            self.tips1Label.hidden = YES;
        }else{
            self.tips1Label.hidden = NO;
        }
    }else if (textField == self.mynewPsdTextField){
        [self.mynewPsdTextField resignFirstResponder];
        [self.againTextField becomeFirstResponder];
        if ([self judgePsdRule:self.mynewPsdTextField.text]) {
            self.tips2Label.hidden = YES;
        }else{
            self.tips2Label.hidden = NO;
        }
    }else if (textField == self.againTextField){
        [self.againTextField resignFirstResponder];
        if ([self judgePsdRule:self.againTextField.text] && [self.mynewPsdTextField.text isEqualToString:self.againTextField.text]) {
            self.tips3Label.hidden = YES;
        }else if (![self.mynewPsdTextField.text isEqualToString:self.againTextField.text]){
            self.tips3Label.hidden = NO;
            self.tips3Label.text = @"2次输入不一致";
        }else{
            self.tips3Label.hidden = NO;
            self.tips3Label.text = @"密码不符合规则请重新输入";
        }
    }
    
    return YES;
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (IBAction)commit:(UIButton *)sender {
    
    [self closeAllTextField];
    
    if (![self judgePsdRule:self.oldPsdTextField.text]) {
        self.tips1Label.hidden = NO;
    }else if (![self judgePsdRule:self.mynewPsdTextField.text]){
        self.tips2Label.hidden = NO;
    }else if (![self judgePsdRule:self.againTextField.text]){
        self.tips3Label.hidden = NO;
        self.tips3Label.text = @"密码不符合规则请重新输入";
    }else if (![self.mynewPsdTextField.text isEqualToString:self.againTextField.text]){
        self.tips3Label.hidden = NO;
        self.tips3Label.text = @"2次输入不一致";
    }else{
        
        self.tips1Label.hidden = YES;
        self.tips2Label.hidden = YES;
        self.tips3Label.hidden = YES;
        
        NSString *oldPassword = [AppUtils trimWhite:self.oldPsdTextField.text];
        NSString *newPassword = [AppUtils trimWhite:self.mynewPsdTextField.text];
        self.commitBtn.enabled = NO;
        
        [self postChangePsd:oldPassword newPassword:newPassword];
    }
}

- (void)closeAllTextField
{
    if ([self.oldPsdTextField isFirstResponder]) {
        [self.oldPsdTextField resignFirstResponder];
    }else if ([self.mynewPsdTextField isFirstResponder]){
        [self.mynewPsdTextField resignFirstResponder];
    }else if ([self.againTextField isFirstResponder]){
        [self.againTextField resignFirstResponder];
    }
}

// 密码判断规则
- (BOOL)judgePsdRule:(NSString *)string
{
    if (![self judgeCharacterInString:string]) {
        return NO;
    }
    
    if (![self judgeStringLength:string]) {
        return NO;
    }
    
    return YES;
}

// 字符串判断
- (BOOL)judgeCharacterInString:(NSString *)string
{
    const char * strings = [string UTF8String];
    for (int i = 0; i < sizeof(strings); i++) {
//        //只能为字母、下划线、数字
//        if (!((*strings >= 65 && *strings <= 90)||(*strings >= 97 && *strings <= 122)||(*strings == 95)||(*strings >= 48 && *strings <=57))) {
//            return NO;
//        }
        
        //as32 - 126
        if (!((*strings >= 65 && *strings <= 90)||(*strings >= 97 && *strings <= 122)||(*strings == 95)||(*strings >= 48 && *strings <=57))) {
            return NO;
        }
    }
    
    //不能有空格
    NSRange range = [string rangeOfString:@" "];
    if (range.length != 0) {
        return NO;
    }
    
    return YES;
}

//判断字符串长度
- (BOOL)judgeStringLength:(NSString *)string
{
    NSRange range = [string rangeOfString:string];
    if (range.length < 6 || range.length > 12) {
        return NO;
    }
    
    return YES;
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
