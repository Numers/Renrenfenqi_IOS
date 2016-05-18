//
//  MyBillsPaymentSuccessViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsPaymentSuccessViewController.h"
#import "AppUtils.h"
//#import "MyBillsViewController.h"
#import "CurMonthRepaymentViewController.h"
#import "OrderFirstPaymentViewController.h"
#import "AppDelegate.h"

@interface MyBillsPaymentSuccessViewController ()

@end

@implementation MyBillsPaymentSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewBg.layer.cornerRadius = 10;
    self.viewBg.layer.borderWidth = 0.5 ;
    self.viewBg.layer.borderColor = [GENERAL_COLOR_GRAY CGColor];
    
    self.lblRepaymentMoney.text = [NSString stringWithFormat:@"还款金额：¥%0.2f", self.payMoney];
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

- (IBAction)doBillDetailAction:(id)sender {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *theVC in allViewControllers) {
        if ([theVC isKindOfClass:[CurMonthRepaymentViewController class]]) {
            [self.navigationController popToViewController:theVC animated:NO];
            [AppUtils popToPage:self targetVC:theVC];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_REPAYMENT_OK object:self];

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
