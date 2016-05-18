//
//  BillPaymentPerMonthViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/6.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "BillPaymentPerMonthViewController.h"
#import "BillDetailViewController.h"
#import "LateFeeViewController.h"
#import "AppUtils.h"
#import "RFBillHomeManager.h"
#import "RFBill.h"

@interface BillPaymentPerMonthViewController ()
{
    NSString *yearMonth; //账单月
    NSString *latestPayDay; //最晚还款日
    NSString *lateFee; //滞纳金
    NSString *needPay; //本月应还
    NSString *hasPay; //本月已还
    NSString *moreDays; //逾期天数
    NSString *status; //逾期标示
    NSString *calRepaymentMoney; //需要还的金额
    NSInteger distanceDays; //距离还款日几天
    
    NSArray *billArray; //账单列表
    
    NSString *selectMonth;
    NSString *selectType;
}
@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@end

@implementation BillPaymentPerMonthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
    
    NSArray *arr = [selectMonth componentsSeparatedByString:@"-"];
    if (arr || (arr.count > 2)) {
        [self.titleLabel setText:[NSString stringWithFormat:@"%@-%@月账单",arr[0],arr[1]]];
    }
}

-(void)setMonth:(NSString *)month WithType:(NSString *)type
{
    selectMonth = month;
    selectType = type;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBillInfoWithMonth:selectMonth WithType:selectType];
}

-(void)getBillInfoWithMonth:(NSString *)month WithType:(NSString *)type;
{
    [[RFBillHomeManager defaultManager] getPerMonthBillInfoWithMonth:month WithType:type Success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *dic = (NSDictionary *)responseObject;
        if (dic) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data) {
                yearMonth = [data objectForKey:@"year_month"];
                latestPayDay = [data objectForKey:@"latest_pay_day"];
                lateFee = [data objectForKey:@"late_fee"];
                needPay = [data objectForKey:@"need_pay"];
                hasPay = [data objectForKey:@"has_pay"];
                moreDays = [data objectForKey:@"more_days"];
                status = [data objectForKey:@"status"];
                calRepaymentMoney = [data objectForKey:@"cal_repayment_money"];
                distanceDays = [[data objectForKey:@"distance_days"] integerValue];
                NSArray *billArr = [data objectForKey:@"bills"];
                if (billArr) {
                    NSMutableArray *bill = [[NSMutableArray alloc] init];
                    for (NSDictionary *m in billArr) {
                        RFBill *b = [[RFBill alloc] init];
                        [b setUpWithDic:m];
                        [bill addObject:b];
                    }
                    billArray = [NSArray arrayWithArray:bill];
                }else{
                    billArray = [NSArray array];
                }
                [self.tableList reloadData];
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(IBAction)clilckBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
    if ((indexPath.row > 3) && (billArray.count > 0)) {
        RFBill *bill = [billArray objectAtIndex:indexPath.row - 4];
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([bill.type isEqualToString:@"late_fee"]) {
            LateFeeViewController *lateFeeVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LateFeeIdentifier"];
            [lateFeeVC updateUIWithBill:bill WithDays:moreDays WithNeedPay:nil];
            [AppUtils pushPage:self targetVC:lateFeeVC];
        }else{
            BillDetailViewController *billDetailVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BillDetailIdentifier"];
            [billDetailVC updateUIWithBill:bill];
            [AppUtils pushPage:self targetVC:billDetailVC];
        }
    }
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 90;
    } else if (indexPath.row == 1) {
        return 50;
    }
    else if (indexPath.row == 2){
        return 10.0f;
    }
    else if(indexPath.row == 3){
        
        return 44;
    }else{
        RFBill *bill = [billArray objectAtIndex:indexPath.row - 4];
        if ([bill.typeName isEqualToString:@"滞纳金"]){
            return 65.0f;
        }else{
            return 44.0f;
        }
    }
    return 0.1f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (billArray) {
        return billArray.count + 4;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
        
        UILabel *lblNeedPayMoney = (UILabel *)[cell viewWithTag:1];
        UILabel *lblPaidMoney = (UILabel *)[cell viewWithTag:2];
        
        lblNeedPayMoney.text = needPay;
        lblPaidMoney.text = hasPay;
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepaymentDateIdentifier" forIndexPath:indexPath];
        UILabel *lblDistanceDays = (UILabel *)[cell viewWithTag:1];
        if (lblDistanceDays) {
            [lblDistanceDays setText:[NSString stringWithFormat:@"距还款日:%ld天",(long)distanceDays]];
        }
        UILabel *lblLatestPayDay = (UILabel *)[cell viewWithTag:2];
        if (lblLatestPayDay) {
            [lblLatestPayDay setText:[NSString stringWithFormat:@"最晚还款日:%@",latestPayDay]];
        }
    }else if(indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
    }else if(indexPath.row == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:@"TitleIdentifier" forIndexPath:indexPath];
    }
    else {
        if (billArray) {
            if ((indexPath.row > 3) && (billArray.count > 0)) {
                RFBill *bill = [billArray objectAtIndex:indexPath.row - 4];
                if ([bill.typeName isEqualToString:@"滞纳金"]) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"RepaymentDateLateIdentifier" forIndexPath:indexPath];
                    UILabel *lblMoreDays = (UILabel *)[cell viewWithTag:1];
                    [lblMoreDays setText:[NSString stringWithFormat:@"超过还款日%@天",moreDays]];
                    UILabel *lblMoney = (UILabel *)[cell viewWithTag:2];
                    if ([status isEqualToString:@"1"]) {
                        [lblMoney setText:[NSString stringWithFormat:@"已产生滞纳金%@元",lateFee]];
                    }else if ([status isEqualToString:@"3"]){
                        [lblMoney setText:[NSString stringWithFormat:@"已还滞纳金%@元",lateFee]];
                    }
                    UILabel *lblLastestPayDay  = (UILabel *)[cell viewWithTag:3];
                    [lblLastestPayDay setText:[NSString stringWithFormat:@"最晚还款日:%@",latestPayDay]];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                    
                    UILabel *lblMoney = (UILabel *)[cell viewWithTag:1];
                    [lblMoney setText:bill.money];
                    UILabel *lblType = (UILabel *)[cell viewWithTag:2];
                    [lblType setText:bill.typeName];
                    UILabel *lblState = (UILabel *)[cell viewWithTag:3];
                    [lblState setText:bill.statusMsg];
                }
            }
        }
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

@end
