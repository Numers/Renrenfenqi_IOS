//
//  BillsListViewController.m
//  renrenfenqi
//
//  Created by coco on 15-5-4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "BillsListViewController.h"
#import "AppUtils.h"
#import "RFBillHomeManager.h"
#import "BillPaymentPerMonthViewController.h"

@interface BillsListViewController ()
{
    NSArray *repayedBillArray; //已还账单列表
}
@end

@implementation BillsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getRepayedBill];
}

-(IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getRepayedBill
{
    [[RFBillHomeManager defaultManager] getRePayedBillInfoSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSArray *dataArr = [resultDic objectForKey:@"data"];
            if (dataArr) {
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (NSDictionary *m in dataArr) {
                    [arr addObject:m];
                }
                if (arr.count > 0) {
                    repayedBillArray = [NSArray arrayWithArray:arr];
                }else{
                    repayedBillArray = [NSArray array];
                }
                [self.tableList reloadData];
            }

        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        [AppUtils showError:[responseObject valueForKey:@"message"]];
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showError:error.description];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [repayedBillArray objectAtIndex:indexPath.row];
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BillPaymentPerMonthViewController *billPaymentPerMonthVC = [mainStory instantiateViewControllerWithIdentifier:@"BillPaymentPerMonthIdentifier"];
    [billPaymentPerMonthVC setMonth:[dic objectForKey:@"year_month"] WithType:@"repayment"];
    [AppUtils pushPage:self targetVC:billPaymentPerMonthVC];
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return repayedBillArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row == repayedBillArray.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepaymentDateTipIdentifier" forIndexPath:indexPath];
        
        UILabel *lblTip = (UILabel *)[cell viewWithTag:1];
        lblTip.text = @"每月5、15、25日为账单日，可查询上个月账单！";
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        NSDictionary *dic = [repayedBillArray objectAtIndex:indexPath.row];
        UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
        UILabel *lblMonth = (UILabel *)[cell viewWithTag:2];
        [lblMonth setText:[dic objectForKey:@"repayment_day"]];
        UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
        NSString *payMoney = [dic objectForKey:@"monthly_pay"];
        if ([payMoney integerValue] == 0) {
            [lblMoney setText:@"已还款"];
        }else{
            [lblMoney setText:payMoney];
        }
        [imgTitle setImage:[UIImage imageNamed:@"creditaccount_body_monthly_n.png"]];
    }
    
    return cell;
}

@end
