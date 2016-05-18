//
//  MyBillsOrderDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsOrderDetailViewController.h"
#import "AppUtils.h"

@interface MyBillsOrderDetailViewController ()
{
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation MyBillsOrderDetailViewController

- (void)addLine:(float)theTop view:(UIView *)view {
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15.0, theTop, _viewWidth - 30.0, 0.5)];
    line1.backgroundColor = GENERAL_COLOR_GRAY;
    [view addSubview:line1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    UIView *line = [AppUtils makeLine:_viewWidth theTop:63.0];
    [self.view addSubview:line];
    MyLog(@"count = %d", (int)self.orderArr.count);
    
    float theViewTop = 0.0;
    float theTop = 0.0;
    for (id orderItem in self.orderArr) {
        MyLog(@"viewTop %f", theViewTop);
        theTop = 12.0;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, theViewTop, _viewWidth, 220.0)];
        view.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:view];
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth / 2 - 100.0, theTop, 200.0, 21.0)];
        lblTitle.font = GENERAL_FONT13;
        lblTitle.text = [NSString stringWithFormat:@"订单号%@", [orderItem objectForKey:@"business_no"]];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        [view addSubview:lblTitle];
        
        theTop += 21.0 + 10.0;
        [self addLine:theTop view:view];
        
        theTop += 5.0;
        UILabel *lblGoodsName = [[UILabel alloc] initWithFrame:CGRectMake(15.0, theTop, _viewWidth - 30.0, 35.0)];
        lblGoodsName.font = GENERAL_FONT13;
        lblGoodsName.text = [orderItem objectForKey:@"goods_name"];
        lblGoodsName.numberOfLines = 2;
        [view addSubview:lblGoodsName];
        
        theTop += 35.0 + 4.0;
        [self addLine:theTop view:view];
        
        theTop += 12.0;
        UILabel *lblOrderTotalTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, theTop, 100.0, 21.0)];
        lblOrderTotalTitle.font = GENERAL_FONT13;
        lblOrderTotalTitle.text = @"订单金额：";
        [view addSubview:lblOrderTotalTitle];
        
        UILabel *lblOrderTotal = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 100.0 - 15.0, theTop, 100.0, 21.0)];
        lblOrderTotal.font = GENERAL_FONT13;
        lblOrderTotal.text = [NSString stringWithFormat:@"¥ %@", [orderItem objectForKey:@"goods_price"]];
        lblOrderTotal.textAlignment = NSTextAlignmentRight;
        [view addSubview:lblOrderTotal];
        
        theTop += 21.0 + 11.0;
        [self addLine:theTop view:view];
        
        theTop += 12.0;
        UILabel *lblPeriodsTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, theTop, 100.0, 21.0)];
        lblPeriodsTitle.font = GENERAL_FONT13;
        lblPeriodsTitle.text = @"分期状态：";
        [view addSubview:lblPeriodsTitle];
        
        UILabel *lblPeriods = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 100.0 - 15.0, theTop, 100.0, 21.0)];
        lblPeriods.font = GENERAL_FONT13;
        lblPeriods.text = [NSString stringWithFormat:@"第%@/%@期", [orderItem objectForKey:@"now_period"], [orderItem objectForKey:@"periods"]];
        lblPeriods.textAlignment = NSTextAlignmentRight;
        [view addSubview:lblPeriods];
        
        theTop += 21.0 + 11.0;
        [self addLine:theTop view:view];
        
        theTop += 12.0;
        UILabel *lblMonthPaymentTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, theTop, 100.0, 21.0)];
        lblMonthPaymentTitle.font = GENERAL_FONT13;
        lblMonthPaymentTitle.text = @"月供金额：";
        [view addSubview:lblMonthPaymentTitle];
        
        UILabel *lblMonthPayment = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 100.0 - 15.0, theTop, 100.0, 21.0)];
        lblMonthPayment.font = GENERAL_FONT13;
        lblMonthPayment.text = [NSString stringWithFormat:@"¥ %@", [orderItem objectForKey:@"money"]];
        lblMonthPayment.textAlignment = NSTextAlignmentRight;
        [view addSubview:lblMonthPayment];
        
        theTop += 21.0 + 11.0;
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, theTop, _viewWidth, 0.5)];
        line1.backgroundColor = GENERAL_COLOR_GRAY;
        [view addSubview:line1];
        
        theViewTop += 220.0 + 15.0;
    }
    
    [self.scrollView setContentSize:CGSizeMake(80.0, theViewTop + 100.0)];
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
@end
