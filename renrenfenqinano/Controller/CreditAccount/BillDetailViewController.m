//
//  BillDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 15-5-4.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "BillDetailViewController.h"
#import "AppUtils.h"
#import "UIImageView+WebCache.h"
#import "RFBillHomeManager.h"
#import "RFBill.h"

@interface BillDetailViewController ()
{
    RFBill *bill;
}

@end

@implementation BillDetailViewController

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
        [self getBillInfo];
    }
}

-(void)getBillInfo
{
    [[RFBillHomeManager defaultManager] getBillInfoWithBusinessNo:bill.businessNo WithType:bill.type Success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
            if (dataDic) {
                bill.imageUrl = [dataDic objectForKey:@"img_path"];
                bill.goodsName = [dataDic objectForKey:@"goods_name"];
            }
        }
        [self.tableList reloadData];
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.tableList reloadData];
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableList reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goback:(id)sender
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
    if (indexPath.row == 0) {
        return 35;
    } else if (indexPath.row == 1) {
        return 85;
    }else if (indexPath.row == 2){
        return 10;
    }
    
    return 44;
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
    if (indexPath.row == 0) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"OrderNoIdentifier" forIndexPath:indexPath];
        
        UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
        UILabel *lblOrderNo = (UILabel *)[cell viewWithTag:2];
        [lblOrderNo setText:bill.businessNo];
        
    } else if (indexPath.row == 1) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"GoodsIdentifier" forIndexPath:indexPath];
        
        UIImageView *imgGoods = (UIImageView *)[cell viewWithTag:1];
        [imgGoods sd_setImageWithURL:[NSURL URLWithString:bill.imageUrl] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
        UILabel *lblGoodsTitle = (UILabel *)[cell viewWithTag:2];
        [lblGoodsTitle setText:bill.goodsName];
    }else if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
    }
    else if(indexPath.row == 3){
        cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier1" forIndexPath:indexPath];
        
        UILabel *lblMoney = (UILabel *)[cell viewWithTag:1];
        
        [lblMoney setText:[NSString stringWithFormat:@"月供：%@",bill.money]];
    }else if(indexPath.row == 4){
        cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier2" forIndexPath:indexPath];
        
        UILabel *lblMonth = (UILabel *)[cell viewWithTag:1];
        [lblMonth setText:[NSString stringWithFormat:@"期数：%@/%@",bill.nowPeriod,bill.periods]];
    }else if(indexPath.row == 5){
        cell= [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier3" forIndexPath:indexPath];
        
        UILabel *lblStatus = (UILabel *)[cell viewWithTag:1];
        [lblStatus setText:[NSString stringWithFormat:@"状态：%@",bill.statusMsg]];
    }
    
    return cell;
}

@end
