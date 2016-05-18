//
//  MyBillsAutoRepaymentViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsAutoRepaymentViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "CommonWebViewController.h"
#import "MyBillsAutoRepaymentOKViewController.h"

@interface MyBillsAutoRepaymentViewController ()
{
    BOOL _isAgree;
    NSMutableDictionary *_selectedBank;
    NSDictionary *_accountInfo;
    
    NSMutableDictionary *_holdingInfo;
}

@end

@implementation MyBillsAutoRepaymentViewController

/**
    获取用户代扣资料
 */
- (void)getWithholdingInfoFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, GET_WITHHOLDINGINFO];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            id temp = [jsonData objectForKey:@"data"];
            if (![temp isKindOfClass:[NSArray class]]) {
                _holdingInfo = [jsonData objectForKey:@"data"];
                
                self.txtBankName.text = [_holdingInfo objectForKey:@"bank_name"];
                self.txtBankCard.text = [_holdingInfo objectForKey:@"card"];
                self.txtIDCard.text = [_holdingInfo objectForKey:@"identity_code"];
                self.txtCardHolderName.text = [_holdingInfo objectForKey:@"card_holder"];
                self.txtPhone.text = [_holdingInfo objectForKey:@"media_id"];
                _selectedBank = [@{@"key":[_holdingInfo objectForKey:@"bank_select"], @"name":[_holdingInfo objectForKey:@"bank_name"]} mutableCopy];
            }
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

/**
    提交代扣资料
 */
- (void)submitAutoRepaymentSetting:(NSString *)bankSelect bankName:(NSString *)bankName card:(NSString *)card IDCard:(NSString *)idcard
                        cardHolder:(NSString *)cardHolder mobile:(NSString *)mobile
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"bank_select":bankSelect,
                                 @"card":card,
                                 @"identity_code":idcard,
                                 @"card_holder":cardHolder,
                                 @"media_id":mobile
                                 };
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, SUBMIT_WITHHOLDING_SETTING];
    [manager POST:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showSuccess:@"自动扣款设置成功！"];
            
            MyBillsAutoRepaymentOKViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsAutoRepaymentOKIdentifier"];
            vc.bankInfo = @{@"bankHolder":cardHolder, @"bankTrail":[card substringFromIndex:(card.length - 4)], @"bankName":bankName};
            [AppUtils pushPage:self targetVC:vc];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
//    _viewWidth = self.view.bounds.size.width;
//    _viewHeight = self.view.bounds.size.height;
    _holdingInfo = [NSMutableDictionary dictionary];
    
    _isAgree = YES;
    
    _accountInfo = [AppUtils getUserInfo];
    
    _selectedBank = [NSMutableDictionary dictionaryWithDictionary:@{@"key":@"-1", @"name":@"nobank"}];
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self getWithholdingInfoFromAPI];
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

- (IBAction)doBankSelectAction:(id)sender {
    MyBillsBankSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsBankSelectIdentifier"];
    vc.delegate = self;
    vc.selectedBank = _selectedBank;
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

/**
    同意或不同意
 */
- (IBAction)doAgreeAction:(id)sender {
    _isAgree = !_isAgree;
    if (_isAgree) {
        [self.btnAgree setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_h"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAgree setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_n"] forState:UIControlStateNormal];
    }
}

- (IBAction)doAgreementAction:(id)sender {
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CommonWebViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_LINKAGE;
    vc.titleString = @"联动优势客户服务协议";
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doSubmitAction:(id)sender {
    NSString *theBankName = [_selectedBank objectForKey:@"name"];
    NSString *theBankSelect = [_selectedBank objectForKey:@"key"];
    if ([theBankSelect floatValue] < 0) {
        [AppUtils showInfo:@"请选择代扣银行"];
        return;
    }
    
    NSString *theBankCard = [AppUtils trimWhite:self.txtBankCard.text];
    if (theBankCard.length <= 0) {
        [AppUtils showInfo:@"请输入银行卡号"];
        return;
    }
    
    NSString *theIDCard = [[AppUtils trimWhite:self.txtIDCard.text] uppercaseString];
    if (theIDCard.length <= 0) {
        [AppUtils showInfo:@"请输入身份证号"];
        return;
    }
    if (![AppUtils isIDCardNumber:theIDCard]) {
        [AppUtils showInfo:@"身份证号码格式不正确"];
        return;
    }
    
    NSString *theName = [AppUtils trimWhite:self.txtCardHolderName.text];
    if (theName.length <= 0) {
        [AppUtils showInfo:@"请输入姓名"];
        return;
    }
    
    NSString *thePhone = [AppUtils trimWhite:self.txtPhone.text];
    if (thePhone.length <= 0) {
        [AppUtils showInfo:@"手机号码不能为空"];
        return;
    }
    if (![AppUtils isMobileNumber:thePhone]) {
        [AppUtils showInfo:@"手机号码格式不正确"];
        return;
    }
    
    if (!_isAgree) {
        [AppUtils showInfo:@"还未同意注册协议！"];
        return;
    }
    
    [self submitAutoRepaymentSetting:theBankSelect bankName:theBankName card:theBankCard IDCard:theIDCard cardHolder:theName mobile:thePhone];
}

#pragma bank select
- (void)MyBillsBankSelectVCDidDismisWithData:(NSObject *)data
{
    _selectedBank = (NSMutableDictionary *)data;
    //TODO
    if ([[_selectedBank objectForKey:@"key"] floatValue] > 0) {
        self.txtBankName.text = [_selectedBank objectForKey:@"name"];
    }
}


@end
