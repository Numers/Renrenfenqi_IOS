//
//  LateFeeViewController.m
//  renrenfenqi
//
//  Created by coco on 15-5-5.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "LateFeeViewController.h"
#import "AppUtils.h"
#import "RFBill.h"
#import "RFBillHomeManager.h"

@interface LateFeeViewController ()
{
    RFBill *bill;
    NSString *lateFee;
    NSString *repaymentMoney;
    NSString *moreDays;
    NSString *rate;
    NSString *statusMsg;
}
@end

@implementation LateFeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
}

-(void)updateUIWithBill:(RFBill *)b
{
    if (b) {
        bill = b;
        [self getLateFeeInfo];
    }
}

-(void)updateUIWithBill:(RFBill *)b WithDays:(NSString *)days WithNeedPay:(NSString *)needPay
{
    if (b) {
        bill = b;
        lateFee = b.money;
        moreDays = days;
        repaymentMoney = needPay;
        statusMsg = b.statusMsg;
        [self.tableList reloadData];
    }
}

-(void)getLateFeeInfo
{
    [[RFBillHomeManager defaultManager] getCurMonthLateFeeInfoSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
            if (dataDic) {
                lateFee = [dataDic objectForKey:@"late_fee"];
                repaymentMoney = [dataDic objectForKey:@"repayment_money"];
                moreDays = [dataDic objectForKey:@"more_days"];
                rate = [dataDic objectForKey:@"rate"];
                statusMsg = [dataDic objectForKey:@"status_msg"];
                [self.tableList reloadData];
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        [AppUtils showInfo:[responseObject objectForKey:@"message"]];
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"网络连接失败!"]; 
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.1f;
    switch (indexPath.row) {
        case 0:
        {
            if (lateFee) {
                height = 44.0f;
            }
        }
            break;
        case 1:
        {
            if (repaymentMoney) {
                height = 44.0f;
            }

        }
            break;
        case 2:
        {
            if (moreDays) {
                height = 44.0f;
            }

        }
            break;
        case 3:
        {
            if (rate) {
                height = 44.0f;
            }

        }
            break;
        case 4:
        {
            if (statusMsg) {
                height = 44.0f;
            }

        }
            break;
        case 5:
        {
            height = 44.0f;
        }
            break;
            
        default:
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
        {
            if (lateFee) {
                cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                [lblTitle setText:[NSString stringWithFormat:@"滞纳金：¥%@",lateFee]];
            }else{
                cell = [[UITableViewCell alloc] init];
            }
        }
            break;
        case 1:
        {
            if (repaymentMoney) {
                cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                [lblTitle setText:[NSString stringWithFormat:@"本月剩余应还金额：¥%@",repaymentMoney]];
            }else{
                cell = [[UITableViewCell alloc] init];
            }
        }
            break;
        case 2:
        {
            if (moreDays) {
                cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                [lblTitle setText:[NSString stringWithFormat:@"本月逾期天数：%@天",moreDays]];
            }else{
                cell = [[UITableViewCell alloc] init];
            }
        }
            break;
        case 3:
        {
            if (rate) {
                cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                [lblTitle setText:[NSString stringWithFormat:@"日利息：%@%%",rate]];
            }else{
                cell = [[UITableViewCell alloc] init];
            }
        }
            break;
        case 4:
        {
            if (statusMsg) {
                cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                [lblTitle setText:[NSString stringWithFormat:@"状态：%@",statusMsg]];
            }else{
                cell = [[UITableViewCell alloc] init];
            }
        }
            break;
        case 5:
        {
            cell= [tableView dequeueReusableCellWithIdentifier:@"TipIdentifier" forIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end
