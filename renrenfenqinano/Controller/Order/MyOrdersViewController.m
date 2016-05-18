//
//  MyOrdersViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyOrdersViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "OrderFirstPaymentViewController.h"
#import "OrderDetailViewController.h"
#import "OrderJobPaymentViewController.h"

@interface MyOrdersViewController ()
{
    NSDictionary *_accountInfo;
    NSMutableArray *_orders;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation MyOrdersViewController

- (NSString *)makeFirstPaymentStatusStr:(NSString*)statusValue
{
    NSString *statusStr = @"";
    switch ([statusValue intValue]) {
        case 1:
            statusStr = @"";
            break;
        case 2:
            statusStr = @"等待付款";
            break;
        case 3:
            statusStr = @"已付首付";
            break;
            
        default:
            break;
    }
    
    return statusStr;
}

- (NSString *)makeJobPaymentStatusStr:(NSString*)statusValue
{
    NSString *statusStr = @"";
    switch ([statusValue intValue]) {
        case 0:
            statusStr = @"兼职处理中";
            break;
        case 1:
            statusStr = @"兼职还款中";
            break;
        case 2:
            statusStr = @"现金还款";
            break;
        case 3:
            statusStr = @"兼职完成";
            break;
            
        default:
            break;
    }
    
    return statusStr;
}

/**
    接口：获取订单列表
 */
- (void)getOrdersFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, ORDER_LIST];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _orders = [jsonData objectForKey:@"data"];
            
            if (_orders.count > 0) {
                [self.orderList reloadData];
            }
            else
            {
                self.blankView.hidden = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _accountInfo = [AppUtils getUserInfo];
    
    if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
        [self backAction:nil];
        [AppUtils showInfo:@"请先登录帐号"];
        return;
    }
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 63.0, _viewWidth, 0.5)];
    line4.backgroundColor = GENERAL_COLOR_GRAY;
    [self.view addSubview:line4];
    
    self.orderList.dataSource = self;
    self.orderList.delegate = self;
    self.orderList.tableFooterView = [UIView new];
    if ([self.orderList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.orderList setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.orderList respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.orderList setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _orders = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getOrdersFromAPI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    
    OrderDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailIdentifier"];
    vc.order = [_orders objectAtIndex:indexPath.row / 2];
    [AppUtils pushPage:self targetVC:vc];
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        NSDictionary *theOrder = [_orders objectAtIndex:indexPath.row / 2];
        if ([[theOrder objectForKey:@"is_job"] isEqualToString:@"1"]) {
            return 205;
        }
        else
        {
            return 161;
        }
    }
    else
    {
        return 10;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _orders.count + (_orders.count - 1);
}

- (NSString *)makeImageUrl:(NSString *)imagePath
{
    return [NSString stringWithFormat:@"%@%@", IMAGE_BASE, imagePath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row % 2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OrderIdentifier" forIndexPath:indexPath];
        
        NSDictionary *theOrder = [_orders objectAtIndex:indexPath.row / 2];
        
        UILabel *lblOrderNo = (UILabel *)[cell viewWithTag:1];
        UILabel *lblOrderStatus = (UILabel *)[cell viewWithTag:2];
        UIImageView *imgGoods = (UIImageView *)[cell viewWithTag:3];
        UILabel *lblGoodsName = (UILabel *)[cell viewWithTag:4];
        UILabel *lblOrderMoney = (UILabel *)[cell viewWithTag:5];
        UILabel *lblMonthPayment = (UILabel *)[cell viewWithTag:6];
        UILabel *lblFirstPayment = (UILabel *)[cell viewWithTag:7];
        UIButton *btnFirstPayment = (UIButton *)[cell viewWithTag:8];
        UILabel *lblFirstPaymentTip = (UILabel *)[cell viewWithTag:9];
        UILabel *lblJobMoney = (UILabel *)[cell viewWithTag:10];
        UIButton *btnJobPayment = (UIButton *)[cell viewWithTag:11];
        btnJobPayment.tag = indexPath.row / 2;
        btnFirstPayment.tag = indexPath.row / 2;
        UILabel *lblJobPaymentTip = (UILabel *)[cell viewWithTag:12];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15.0, 40.0, _viewWidth - 15.0, 0.5)];
        line1.backgroundColor = GENERAL_COLOR_GRAY3;
        [cell addSubview:line1];
        
        UIView *line2 = [AppUtils makeLine:_viewWidth theTop:120.0];
        [cell addSubview:line2];
        
        if ([[theOrder objectForKey:@"is_job"] isEqualToString:@"1"])
        {
            UIView *line3 = [AppUtils makeLine:_viewWidth theTop:160.0];
            [cell addSubview:line3];
            
            if ([[[theOrder objectForKey:@"jobs"] objectForKey:@"status"] isEqualToString:@"2"]) {
                btnJobPayment.hidden = NO;
                lblJobMoney.hidden = NO;
                lblJobPaymentTip.hidden = YES;
                
                lblJobMoney.text = [NSString stringWithFormat:@"兼职金额：¥%@", [[theOrder objectForKey:@"jobs"] objectForKey:@"job_pay_money"]];
            }
            else
            {
                btnJobPayment.hidden = YES;
                lblJobMoney.hidden = NO;
                lblJobPaymentTip.hidden = NO;
                
                lblJobMoney.text = [NSString stringWithFormat:@"兼职天数：%@", [[theOrder objectForKey:@"jobs"] objectForKey:@"job_msg"]];
                lblJobPaymentTip.text = [self makeJobPaymentStatusStr:[[theOrder objectForKey:@"jobs"] objectForKey:@"status"]];
            }
        }
        else
        {
            lblJobMoney.hidden = YES;
            btnJobPayment.hidden = YES;
            lblJobPaymentTip.hidden = YES;
        }
        
        lblOrderNo.text = [NSString stringWithFormat:@"订单号：%@", [theOrder objectForKey:@"business_no"]];
        lblOrderStatus.text = [theOrder objectForKey:@"status_msg"];
        [imgGoods sd_setImageWithURL:[NSURL URLWithString:[theOrder objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
        lblGoodsName.text = [theOrder objectForKey:@"goods_name"];
        lblOrderMoney.text = [NSString stringWithFormat:@"订单金额：¥%@", [theOrder objectForKey:@"goods_price"]];
        lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%@X%@", [[theOrder objectForKey:@"goods_type"] objectForKey:@"monthly_price"], [[theOrder objectForKey:@"goods_type"] objectForKey:@"periods"] ];
        lblFirstPayment.text = [NSString stringWithFormat:@"首付：¥ %@", [[theOrder objectForKey:@"goods_type"] objectForKey:@"first_price"]];
        if ([[theOrder objectForKey:@"first_pay"] isEqualToString:@"2"] &&
            ([[theOrder objectForKey:@"status"] isEqualToString:@"5"] || [[theOrder objectForKey:@"status"] isEqualToString:@"15"])
            ) {
            btnFirstPayment.hidden = NO;
            lblFirstPaymentTip.hidden = YES;
        }
        else
        {
            btnFirstPayment.hidden = YES;
            lblFirstPaymentTip.text = [self makeFirstPaymentStatusStr:[theOrder objectForKey:@"first_pay"]];
            
            if ([[theOrder objectForKey:@"status"] isEqualToString:@"-1"] ||
                [[theOrder objectForKey:@"status"] isEqualToString:@"0"]
                )
            {
                lblFirstPaymentTip.text = @"";
            }
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
    }
    
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

- (IBAction)doFirstPaymentAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    OrderFirstPaymentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderFirstPaymentIdentifier"];
    vc.order = [_orders objectAtIndex:btn.tag];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doJobPaymentAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSDictionary *theOrder = [_orders objectAtIndex:btn.tag];
    OrderJobPaymentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderJobPaymentIdentifier"];
    vc.businessNO = [theOrder objectForKey:@"business_no"];
    vc.paymentMoney = [[theOrder objectForKey:@"jobs"] objectForKey:@"job_pay_money"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)backAction:(id)sender {
    [AppUtils goBack:self];
}
@end
