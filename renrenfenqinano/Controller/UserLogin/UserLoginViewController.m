//
//  UserLoginViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "UserLoginViewController.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UserRegisterStep1ViewController.h"
#import "UserForgetPWDStep1ViewController.h"
#import "ImprovePersonalInfoViewController.h"
#import "JobDetailViewController2.h"
#import "OnlyPartTimeViewController.h"

#import "RFGeneralManager.h"

@interface UserLoginViewController ()
{
    UIStoryboard *_secondStorybord;
}

@end

@implementation UserLoginViewController

- (void)submitToLogin:(NSString *)theUserAccount password:(NSString *)thePassword
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:thePassword forKey:@"pwd"];
        [parameters setValue:theUserAccount forKey:@"phone"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_LOGIN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.btnLogin.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"您已成功登录！"];
            [persistentDefaults setObject:[jsonData objectForKey:@"data"] forKey:@"accountInfo"];
            [self storeUserInfo:[jsonData objectForKey:@"data"]];
            
            //上传推送需要的注册ID
            [[RFGeneralManager defaultManager] sendClientIdSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            MyLog(@"%@", [jsonData objectForKey:@"data"]);
            
            //登录成功后
            //检查是否有报名兼职的审核消息变动
            [(AppDelegate *)[UIApplication sharedApplication].delegate checkJobApply];
            
            //TODO JZ 去 完善资料
            if (self.writeInfoMode && [[persistentDefaults objectForKey:@"WriteJobSetting"] isEqualToString:@"yes"]) {
                [persistentDefaults removeObjectForKey:@"WriteJobSetting"];
                [persistentDefaults removeObjectForKey:@"RegInfo"];
                
                if (self.writeInfoMode == WriteInfoModeOption) {
                    ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
                    vc.isSkip = YES;
                    vc.theViewClass = self.parentClass;
                    [AppUtils pushPage:self.parentController targetVC:vc];
                    
                    [self doCloseAction:nil];
                }
                else if (self.writeInfoMode == WriteInfoModeMust)
                {
                    ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
                    vc.isSkip = NO;
                    vc.theViewClass = self.parentClass;
                    [AppUtils pushPage:self.parentController targetVC:vc];
                    
                    [self doCloseAction:nil];
                }
                else
                {
                    [self doCloseAction:nil];
                }
            }
            else
            {
                [self doCloseAction:nil];
            }
            
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        self.btnLogin.enabled = YES;
    }];
}

// 存储用户登录信息
- (void)storeUserInfo:(NSDictionary *)dic{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.store putString:[AppUtils filterNull:[[dic objectForKey:@"info"] objectForKey:@"uid"]] withId:USER_ID intoTable:USER_TABLE];
    [app.store putString:[AppUtils filterNull:[[dic objectForKey:@"info"] objectForKey:@"nikename"]] withId:USER_NICKNAME intoTable:USER_TABLE];
    [app.store putString:[AppUtils filterNull:[[dic objectForKey:@"info"] objectForKey:@"avatar"] ] withId:USER_HEAD_PIC intoTable:USER_TABLE];
    [app.store putString:[AppUtils filterNull:[dic objectForKey:@"token"]] withId:USER_TOKEN intoTable:USER_TABLE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_ONLY_PARTTIME_DATA object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_JOB_DETAIL object:nil];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    [persistentDefaults removeObjectForKey:@"WriteJobSetting"];
    
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    self.tableLogin.dataSource = self;
    self.tableLogin.delegate = self;
    
    UIView *lineView = [AppUtils makeLine:self.view.bounds.size.width theTop:98.0];
    [self.view addSubview:lineView];
    
    UIView *lineView2 = [AppUtils makeLine:self.view.bounds.size.width theTop:187.0];
    [self.view addSubview:lineView2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([[persistentDefaults objectForKey:@"WriteJobSetting"] isEqualToString:@"yes"]) {
        if ([persistentDefaults objectForKey:@"RegInfo"]) {
            NSArray *arrRegInfo = [[persistentDefaults objectForKey:@"RegInfo"] componentsSeparatedByString:@"|"];
            if (arrRegInfo.count > 0) {
                [self submitToLogin:arrRegInfo[0] password:arrRegInfo[1]];
            }
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 44.0;
    
    if (indexPath.row == 1) {
        height = 45.0;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AccountIdentifier" forIndexPath:indexPath];
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordIdentifier" forIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
    
    UITextField *txt = (UITextField *)[cell viewWithTag:1];
    txt.delegate = self;
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignAllFirstResponder];
    return YES;
}

- (IBAction)doCloseAction:(id)sender {
//    [AppUtils goBack:self];
    [AppUtils goBackFromTopToBottom:self];
}

- (IBAction)doRegisterAction:(id)sender {
    UserRegisterStep1ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserRegisterStep1Identifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doForgetPasswordAction:(id)sender {
    UserForgetPWDStep1ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserForgetPWDStep1Identifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doLoginAction:(id)sender {
    
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell1 = [self.tableLogin cellForRowAtIndexPath:indexPath1];
    UITextField *txtUserAccount = (UITextField *)[cell1 viewWithTag:1];
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell2 = [self.tableLogin cellForRowAtIndexPath:indexPath2];
    UITextField *txtUserPassword = (UITextField *)[cell2 viewWithTag:1];
    
    NSString *theUserAccount = [AppUtils trimWhite:txtUserAccount.text];
    NSString *thePassword = [AppUtils trimWhite:txtUserPassword.text];
    if ([theUserAccount isEqualToString:@""] || [thePassword isEqualToString:@""]) {
        [AppUtils showInfo:@"用户名和密码不能为空"];
        return;
    }
    
    if (theUserAccount.length < 2 || thePassword.length < 2) {
        [AppUtils showInfo:@"用户名或密码过短"];
        return;
    }
    
    self.btnLogin.enabled = NO;
    [self submitToLogin:theUserAccount password:thePassword];
}
@end
