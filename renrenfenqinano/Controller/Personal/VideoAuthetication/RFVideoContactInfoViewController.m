//
//  RFVideoContactInfoViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/25.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFVideoContactInfoViewController.h"
#import "Student.h"
#import "RFAuthManager.h"
#import "AppUtils.h"
#import "RFSelectBookTimeViewController.h"

@interface RFVideoContactInfoViewController ()<UITextFieldDelegate>
{
    Student *currentStudent;
}
@property(nonatomic, strong) IBOutlet UIView *backView;
@property(nonatomic, strong) IBOutlet UIButton *btnComfirm;
@property(nonatomic, strong) IBOutlet UITextField *txtQQContact;
@property(nonatomic, strong) IBOutlet UIButton *btnBookTime;
@end

@implementation RFVideoContactInfoViewController
-(id)initWithStudent:(Student *)student
{
    self = [super init];
    if (self) {
        currentStudent = student;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.backView.layer setCornerRadius:5.0f];
    [self.backView.layer setMasksToBounds:YES];
    
    [self.btnComfirm.layer setCornerRadius:5.0f];
    [self.btnComfirm.layer setMasksToBounds:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIView];
}

-(void)updateUIView
{
    if (currentStudent.videoQQ && currentStudent.videoQQ.length > 0) {
        _txtQQContact.text = currentStudent.videoQQ;
    }
    
    if (currentStudent.videoTime && currentStudent.videoTime.length > 0) {
        [_btnBookTime setTitle:currentStudent.videoTime forState:UIControlStateNormal];
        [_btnBookTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnBookTime setTitle:@"请选择合适的时间" forState:UIControlStateNormal];
        [_btnBookTime setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_txtQQContact isFirstResponder]) {
        [_txtQQContact resignFirstResponder];
    }
}

-(BOOL)validateInput
{
    UIAlertView *alert = nil;
    if (_txtQQContact.text == nil || _txtQQContact.text.length == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入QQ" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        currentStudent.videoQQ = _txtQQContact.text;
    }
    
    if (!currentStudent.videoTime || currentStudent.videoTime.length == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择合适的时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickComfirmBtn:(id)sender
{
    if ([self validateInput]) {
        NSDictionary *loginInfo = [AppUtils getUserInfo];
        NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
        NSString *token = [loginInfo objectForKey:@"token"];
        if ([AppUtils isLogined:uid]) {
            if ([currentStudent.uid isEqualToString:uid]) {
                [[RFAuthManager defaultManager] bookVideoAutheticationWithUid:uid WithToken:token WithQQ:currentStudent.videoQQ WithBookTime:currentStudent.videoTime Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [AppUtils showInfo:@"预约成功,请等待审核人员与您联系"];
                    [self.navigationController popViewControllerAnimated:YES];
                } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [AppUtils showInfo:[responseObject objectForKey:@"message"]];
                } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [AppUtils showInfo:@"网络连接失败"];
                }];
            }
        }
    }
}

-(IBAction)clickSelectBookTimeBtn:(id)sender
{
    RFSelectBookTimeViewController *rfSelectBookTimeVC = [[RFSelectBookTimeViewController alloc] initWithStudent:currentStudent];
    [self.navigationController pushViewController:rfSelectBookTimeVC animated:YES];
}
@end
