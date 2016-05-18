//
//  DeductionViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "DeductionViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "CommonWebViewController.h"
#import "DeductionResultViewController.h"
#import "DeductionConfirmView.h"

@interface DeductionViewController ()
{
    NSMutableArray *_repaymentRedPacketArr; // 还款红包容器
//    NSMutableArray *_selectedRedPacketArr;  // 选中红包容器
    
    float _viewWidth;
    float _viewHeight;
    int   _deduction;      //抵扣金额总值
    int   _maxSelectdValue;//允许选择最大个数
}

@end

static NSString *repaymentCellIdentifiler = @"repaymentCell";
static NSString *cellIdentifiler = @"Cell";

@implementation DeductionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViewData];
    
    self.redPacketList.delegate = self;
    self.redPacketList.dataSource = self;

    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:repaymentCellIdentifiler];
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.redPacketList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.redPacketList setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.redPacketList respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.redPacketList setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self getRedPacketDetailFromAPI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViewData
{
    _repaymentRedPacketArr = [NSMutableArray array];
    
    if (self.selectedRedPacketArr == nil) {
        self.selectedRedPacketArr = [NSMutableArray array];
    }
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _deduction = 0;
    _maxSelectdValue = 5;
}

#pragma mark 数据获取

- (void)getRedPacketDetailFromAPI
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];

    NSDictionary *parameters = @{@"uid":userId,
                                 @"type":[NSString stringWithFormat:@"%d", 2],
                                 @"status":[NSString stringWithFormat:@"%d", 1]};
    
    [AppUtils showLoadIng:@"红包数据加载中"];
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, RED_PACKET_DETAIL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleRedPacketData:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleRedPacketData:(NSArray *)result
{
    [_repaymentRedPacketArr removeAllObjects];
    [_repaymentRedPacketArr addObjectsFromArray:result];
    
    if (self.selectedRedPacketArr.count > 0) {
        
        for (int index = 0; index < self.selectedRedPacketArr.count; index++) {
            for (NSDictionary *dic in _repaymentRedPacketArr){
                if ([[dic objectForKey:@"red_id"] isEqual:[self.selectedRedPacketArr objectAtIndex:index]]) {
                    _deduction += [[dic objectForKey:@"red_money"] intValue];
                }
            }
        }
    }

    [self.redPacketList reloadData];
}

// 处理红包选中状态的刷新
- (void)handleSelectedStatus:(NSIndexPath *)indexPath
{
    NSDictionary *tempDic = [_repaymentRedPacketArr objectAtIndex:indexPath.row];
    NSString *newRedID = [tempDic objectForKey:@"red_id"];
    if (_selectedRedPacketArr.count == 0) {
        [_selectedRedPacketArr addObject:newRedID];
        _deduction += [[tempDic objectForKey:@"red_money"] intValue];
        
        [self.redPacketList reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.redPacketList reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }else if (_selectedRedPacketArr.count > 0 && _selectedRedPacketArr.count < _maxSelectdValue){
        
        BOOL isNeedAdd = YES;
        for (int index = 0; index < _selectedRedPacketArr.count; index++) {
            if ([newRedID isEqual:[_selectedRedPacketArr objectAtIndex:index]]) {
                [_selectedRedPacketArr removeObjectAtIndex:index];
                _deduction -= [[tempDic objectForKey:@"red_money"] intValue];
                isNeedAdd = NO;
            }
        }
        
        if (isNeedAdd) {
            [_selectedRedPacketArr addObject:newRedID];
            _deduction += [[tempDic objectForKey:@"red_money"] intValue];
        }
        
        if (_selectedRedPacketArr.count < _maxSelectdValue) {
            [self.redPacketList reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
            [self.redPacketList reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [self.redPacketList reloadData];
        }
        
    }else if (_selectedRedPacketArr.count >= _maxSelectdValue){
        
        BOOL isNeedRefresh = NO;
        for (int index = 0; index < _selectedRedPacketArr.count; index++) {
            if ([newRedID isEqual:[_selectedRedPacketArr objectAtIndex:index]]) {
                [_selectedRedPacketArr removeObjectAtIndex:index];
                _deduction -= [[tempDic objectForKey:@"red_money"] intValue];
                isNeedRefresh = YES;
            }
            
            if (isNeedRefresh) {
                [self.redPacketList reloadData];
            }
        }
    }else{
        return ;
    }
}

// 判断红包是否选中基于红包ID
- (BOOL)judgeSelected:(NSString *)redID
{
    BOOL isSelected = NO;
    if (_selectedRedPacketArr.count == 0){
        isSelected =  NO;
    }else{
        for (NSString *theRedID in _selectedRedPacketArr){
            if ([theRedID isEqual:redID]) {
                isSelected = YES;
            }
        }
    }
    
    return isSelected;
}

// 使用红包数据接口
- (void)useRedPacketFromAPI:(NSString *)redList thedate:(NSString *)yearmonth
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:redList forKey:@"red_list"];
    [parameters setValue:yearmonth forKey:@"year_month"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];

    [AppUtils showLoadIng:@"红包使用提交中"];
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USE_CON_RED_USE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            // 处理使用红包
            [self handleUsedRedpacket];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleUsedRedpacket
{
    if([self.delegate respondsToSelector:@selector(deduction:)]) {
        [self.delegate deduction:_selectedRedPacketArr];
    }
    
    for (NSString *usedRedId in _selectedRedPacketArr) {
        
        for (int index = 0; index < _repaymentRedPacketArr.count; index++) {
            if ([usedRedId isEqualToString:[[_repaymentRedPacketArr objectAtIndex:index] objectForKey:@"red_id"]]) {
                [_repaymentRedPacketArr removeObjectAtIndex:index];
            }
        }
    }
    
    [_selectedRedPacketArr removeAllObjects];
    [self.redPacketList reloadData];
    
    // 跳转到红包结果界面
    DeductionResultViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"DeductionResultIdentifier"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.billDic = self.billDic;
    vc.redMoneyValue = _deduction;
    [AppUtils pushPage:self targetVC:vc];
    
    _deduction = 0;

}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 44;
        case 1:
            return 150;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row < _repaymentRedPacketArr.count) {
        [self handleSelectedStatus:indexPath];
    }
}

#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex) {
        case 0:
            return _repaymentRedPacketArr.count;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:repaymentCellIdentifiler forIndexPath:indexPath];
            
            NSDictionary *dataDic = [NSDictionary dictionary];
            if (_repaymentRedPacketArr.count <= indexPath.row) {
                return  cell;
            }
            
            UIImageView *imgRedPacket = (UIImageView *)[cell viewWithTag:10];
            if (imgRedPacket == nil) {
                imgRedPacket = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 14.0, 23.0, 17.0)];
                imgRedPacket.image = [UIImage imageNamed:@"home_body_redenvelopes_n@2x.png"];
                imgRedPacket.tag = 10;
                [cell addSubview:imgRedPacket];
            }
            
            UILabel *lblRedMoney = (UILabel *)[cell viewWithTag:11];
            if (lblRedMoney == nil) {
                lblRedMoney = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 8.0, _viewWidth -57, 13)];
                lblRedMoney.font = GENERAL_FONT13;
                lblRedMoney.numberOfLines = 1;
                lblRedMoney.textAlignment = NSTextAlignmentLeft;
                lblRedMoney.tag = 11;
                [cell addSubview:lblRedMoney];
            }
            
            UILabel *lblExpiryDate = (UILabel *)[cell viewWithTag:12];
            if (lblExpiryDate == nil) {
                lblExpiryDate = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 23.0, _viewWidth -57, 12)];
                lblExpiryDate.font = GENERAL_FONT12;
                lblExpiryDate.textColor = UIColorFromRGB(0xa2a2a2);
                lblExpiryDate.numberOfLines = 1;
                lblExpiryDate.textAlignment = NSTextAlignmentLeft;
                lblExpiryDate.tag = 12;
                [cell addSubview:lblExpiryDate];
            }
            
            UIImageView *imgSelectedStatus = (UIImageView *)[cell viewWithTag:13];
            if (imgSelectedStatus == nil) {
                imgSelectedStatus = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 46.0, 10.5, 23.0, 23.0)];
                imgSelectedStatus.tag = 13;
                [cell addSubview:imgSelectedStatus];
            }
            
            dataDic = _repaymentRedPacketArr[indexPath.row];
            NSString *createTime = [dataDic objectForKey:@"create_time"];
            createTime = [createTime substringToIndex:10];
            NSString *expireTime = [dataDic objectForKey:@"expire_time"];
            expireTime = [expireTime substringToIndex:10];
            
            lblRedMoney.text = [NSString stringWithFormat:@"%@元红包",[dataDic objectForKey:@"red_money"]];
            lblExpiryDate.text = [NSString stringWithFormat:@"有效期 %@-%@",createTime,expireTime];
            
            if (_selectedRedPacketArr.count == 0) {
                imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button_n@2x.png"];
            }else if (_selectedRedPacketArr.count < _maxSelectdValue && _selectedRedPacketArr > 0) {
                if ([self judgeSelected:[dataDic objectForKey:@"red_id"]]) {
                    imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button_h@2x.png"];
                }else{
                    imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button_n@2x.png"];
                }
            }else{
                if ([self judgeSelected:[dataDic objectForKey:@"red_id"]]) {
                    imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button_h@2x.png"];
                }else{
                    imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button1_n@2x.png"];
                }
            }
            
            return cell;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
            
            UILabel *lblTitle = (UILabel*)[cell viewWithTag:20];
            if (lblTitle == nil) {
                lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 15.0, 150.0, 13.0)];
                lblTitle.backgroundColor = [UIColor clearColor];
                lblTitle.textColor = [UIColor blackColor];
                lblTitle.font = GENERAL_FONT13;
                lblTitle.numberOfLines = 1;
                lblTitle.textAlignment = NSTextAlignmentLeft;
                lblTitle.tag = 20;
                [cell addSubview:lblTitle];
            }
            
            UIButton *btnRepayment = (UIButton *)[cell viewWithTag:21];
            if (btnRepayment == nil) {
                btnRepayment = [UIButton buttonWithType:UIButtonTypeCustom];
                btnRepayment.backgroundColor = [UIColor clearColor];
                btnRepayment.frame = CGRectMake(15.0, 80, _viewWidth - 30, 40);
                [btnRepayment setImage:[UIImage imageNamed:@"reddeduction_body_complete_n@2x.png"] forState:UIControlStateNormal];
                [btnRepayment setImage:[UIImage imageNamed:@"reddeduction_body_complete_n1@2x.png"] forState:UIControlStateDisabled];
                [btnRepayment addTarget:self action:@selector(doConfirm) forControlEvents:UIControlEventTouchUpInside];
                btnRepayment.tag = 21;
                [cell addSubview:btnRepayment];

            }
            
            lblTitle.text = [NSString stringWithFormat:@"总计抵扣还款额：￥%d", _deduction];
            
            return cell;
        }
        default:
        {
            return nil;
        }
    }
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender
{
    if([self.delegate respondsToSelector:@selector(repaymentRedData:totalValue:)]) {
        [self.delegate repaymentRedData:_selectedRedPacketArr totalValue:_deduction];
    }
    
    [AppUtils goBack:self];
}

- (IBAction)useRule:(id)sender
{
    CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_RED_USE_ROLE;
    vc.titleString = @"红包使用规则";
    [AppUtils pushPage:self targetVC:vc];
}

- (void)doConfirm
{
    if (_deduction <= 0) {
        [AppUtils showLoadInfo:@"无抵扣红包勾选"];
        return;
    }
    
    DeductionConfirmView *confirmView = [[DeductionConfirmView alloc] initWithData:_deduction];
    [confirmView show];
    
    confirmView.dismissBlock = ^(){
        NSLog(@"取消红包抵扣");
    };
    
    confirmView.confirmBlock = ^(){
        NSLog(@"申请使用红包");
        
        [self handleRedData];
    };
}
// 确定之后处理红包使用，
- (void)handleRedData
{
    // 设置自动还款
    if ([[self.billDic objectForKey:@"contract"] intValue] == 1) {
        NSString *redList = [NSString string];
        if (_selectedRedPacketArr.count == 1) {
            redList = [_selectedRedPacketArr objectAtIndex:0];
        }else if (_selectedRedPacketArr.count > 1 && _selectedRedPacketArr.count <= _maxSelectdValue){
            redList = [_selectedRedPacketArr objectAtIndex:0];
            for (int index = 1; index < _selectedRedPacketArr.count; index++) {
                redList = [redList stringByAppendingString:[NSString stringWithFormat:@",%@", [_selectedRedPacketArr objectAtIndex:index]]];
            }
        }else{
            NSLog(@"提醒用户相关错误信息");
            return;
        }
        
        NSString *yearmonth = [[self.billDic objectForKey:@"now"] objectForKey:@"year_month"];
        
        [self useRedPacketFromAPI:redList thedate:yearmonth];
    }else{
//        if([self.delegate respondsToSelector:@selector(repaymentRedData:totalValue:)]) {
//            [self.delegate repaymentRedData:_selectedRedPacketArr totalValue:_deduction];
//            [self back:nil];
//        }
        [self back:nil];
    }
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
