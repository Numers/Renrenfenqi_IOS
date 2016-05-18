//
//  MyBillsAutoRepaymentOKViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-11.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsAutoRepaymentOKViewController.h"
#import "AppDelegate.h"

@interface MyBillsAutoRepaymentOKViewController ()

@end

@implementation MyBillsAutoRepaymentOKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.bankInfo) {
        self.lblBankName.text = [NSString stringWithFormat:@"银行：%@", [self.bankInfo objectForKey:@"bankName"]];
        self.lblBankHolder.text = [NSString stringWithFormat:@"持卡人：%@", [self.bankInfo objectForKey:@"bankHolder"]];
        self.lblBankTrail.text = [NSString stringWithFormat:@"卡号尾数：%@", [self.bankInfo objectForKey:@"bankTrail"]];
    }
 
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

- (IBAction)doMyBillsAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)doGoAction:(id)sender {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tbc = (UITabBarController*)[app.window rootViewController];
    if(![tbc isKindOfClass: [UITabBarController class]]){
        return;
    }
    [tbc setSelectedIndex:0];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
