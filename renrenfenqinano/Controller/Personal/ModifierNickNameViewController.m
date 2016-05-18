//
//  ModifierNickNameViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/3.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ModifierNickNameViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

@interface ModifierNickNameViewController ()


@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@end

@implementation ModifierNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nickNameTextField.text = self.nickNameString;
    self.nickNameTextField.delegate = self;
    self.nickNameTextField.returnKeyType = UIReturnKeyDone;
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nickNameTextField) {
        
        [self.nickNameTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)judgeNickname:(NSString *)string
{
    if ([AppUtils judgeStrIsEmpty:string]) {
        return NO;
    }
    
//    NSRange range = [string rangeOfString:string];
//    if (range.length < 1 || range.length > 12) {
//        return NO;
//    }
    int len = [AppUtils getToInt:string];
    if (len < 2 || len > 24) {
        return NO;
    }
    
    NSRange range = [string rangeOfString:@" "];
    if (range.length != 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (IBAction)commit:(UIButton *)sender {
    
    if ([self.nickNameTextField isFirstResponder]) {
        [self.nickNameTextField resignFirstResponder];
    }
    
    if (![self judgeNickname:self.nickNameTextField.text]) {
        [AppUtils showLoadInfo:@"昵称修改要求2-24个字符，且不能有空格"];
    }else{
        self.commitBtn.enabled = NO;
        [self modifyNickName:self.nickNameTextField.text];
    }
}

- (void)modifyNickName:(NSString *)newNickeName
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:newNickeName forKey:@"name"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [AppUtils showLoadIng:@"昵称修改提交中"];
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, MODIFY_NICKNAME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.commitBtn.enabled = YES;
        
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            [AppUtils showLoadInfo:@"昵称修改成功"];
            if ([self.delegate respondsToSelector:@selector(saveNewNickName:)]) {
                [self.delegate saveNewNickName:newNickeName];
            }
            
            [self back:nil];
            
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        self.commitBtn.enabled = YES;
    }];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
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
