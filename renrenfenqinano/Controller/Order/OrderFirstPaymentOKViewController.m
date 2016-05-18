//
//  OrderFirstPaymentOKViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderFirstPaymentOKViewController.h"
#import "UIImageView+WebCache.h"
//#import "MyOrdersViewController.h"
#import "CreditAccountViewController.h"
#import "AppUtils.h"

@interface OrderFirstPaymentOKViewController ()

@end

@implementation OrderFirstPaymentOKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rectView.layer.cornerRadius = 10;
    self.rectView.layer.borderWidth = 0.5 ;
    self.rectView.layer.borderColor = [GENERAL_COLOR_GRAY CGColor];
    
    [self.goodsImg sd_setImageWithURL:[NSURL URLWithString:[self.order objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    self.lblGoodsName.text = [self.order objectForKey:@"goods_name"];
    self.lblPaymentMoney.text = [NSString stringWithFormat:@"支付金额：¥%@", [self.order objectForKey:@"first_price"]];
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

- (IBAction)doOKAction:(id)sender {
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *theVC in allViewControllers) {
        if ([theVC isKindOfClass:[CreditAccountViewController class]]) {
            [self.navigationController popToViewController:theVC animated:NO];
            [AppUtils popToPage:self targetVC:theVC];
            break;
        }
    }
}
@end
