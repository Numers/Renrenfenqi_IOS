//
//  ShoppingRedPaketViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ShoppingRedPaketViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"


@interface ShoppingRedPaketViewController ()
{
    NSMutableArray *_shoppingRedPacketArr; // 购物红包容器
    
    float _viewWidth;
    float _viewHeight;
    int   _deduction;      //抵扣金额总值
    
    int   _maxSelectdValue; // 允许选择最大个数， 购物红包当前红包默认只支持1个
}

@property (nonatomic, strong) UILabel *tipsLabel; //没有数据提醒

@end

@implementation ShoppingRedPaketViewController

static NSString *redcellIdentifiler = @"redCell"; // 红包显示界面
static NSString *cellIdentifiler1 = @"cell1";     // 按钮界面

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.shoppingRedTableview.delegate = self;
    self.shoppingRedTableview.dataSource = self;
    
    [self initViewData];
    
     self.shoppingRedTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.shoppingRedTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:redcellIdentifiler];
    [self.shoppingRedTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler1];
    
    if ([self.shoppingRedTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.shoppingRedTableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.shoppingRedTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.shoppingRedTableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self getShoppingRedPaketFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据处理

- (void)initViewData
{
    _shoppingRedPacketArr = [NSMutableArray array];
    
    if (self.selectedRedPacketArr == nil) {
         _selectedRedPacketArr = [NSMutableArray array];
    }
    
    _maxSelectdValue = 1;
    _deduction = 0;
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
}

// 获取当前账户的购物红包列表
- (void)getShoppingRedPaketFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid":userId,
                                 @"type":@"1",
                                 @"status":@"1"};
    
    [AppUtils showLoadIng:@""];
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
    [_shoppingRedPacketArr removeAllObjects];
    [_shoppingRedPacketArr addObjectsFromArray:result];
    
    if (self.selectedRedPacketArr.count > 0) {
        
        for (int index = 0; index < self.selectedRedPacketArr.count; index++) {
            for (NSDictionary *dic in _shoppingRedPacketArr){
                if ([[dic objectForKey:@"red_id"] isEqual:[self.selectedRedPacketArr objectAtIndex:index]]) {
                    _deduction += [[dic objectForKey:@"red_money"] intValue];
                }
            }
        }
    }
    
    [self.shoppingRedTableview reloadData];
}

// 处理红包选中状态的刷新显示
- (void)handleSelectedStatus:(NSIndexPath *)indexPath
{
    NSDictionary *tempDic = [_shoppingRedPacketArr objectAtIndex:indexPath.row];
    NSString *newRedID = [tempDic objectForKey:@"red_id"];
    if (_selectedRedPacketArr.count == 0) {
        [_selectedRedPacketArr addObject:newRedID];
        _deduction += [[tempDic objectForKey:@"red_money"] intValue];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.shoppingRedTableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }else if (_selectedRedPacketArr.count > 0 && _selectedRedPacketArr.count < _maxSelectdValue){
        // 购物红包 当前版本只支持1个红包选择可以不用管本case处理
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
            [self.shoppingRedTableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
            [self.shoppingRedTableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [self.shoppingRedTableview reloadData];
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
                [self.shoppingRedTableview reloadData];
            }
        }
    }else{
        return ;
    }
}

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

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return _shoppingRedPacketArr.count;
    }else if (sectionIndex == 1){
        return  1;
    }else{
        return 0;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:redcellIdentifiler forIndexPath:indexPath];
        
        NSDictionary *dataDic = [NSDictionary dictionary];
        if (_shoppingRedPacketArr.count <= indexPath.row) {
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
        
        dataDic = _shoppingRedPacketArr[indexPath.row];
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
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler1 forIndexPath:indexPath];
        
        UIButton *btnRepayment = (UIButton *)[cell viewWithTag:21];
        if (btnRepayment == nil) {
            btnRepayment = [UIButton buttonWithType:UIButtonTypeCustom];
            btnRepayment.backgroundColor = [UIColor clearColor];
            btnRepayment.frame = CGRectMake(15.0, 15, _viewWidth - 30, 40);
            [btnRepayment setImage:[UIImage imageNamed:@"reddeduction_body_complete_n@2x.png"] forState:UIControlStateNormal];
            [btnRepayment setImage:[UIImage imageNamed:@"reddeduction_body_complete_n1@2x.png"] forState:UIControlStateDisabled];
            [btnRepayment addTarget:self action:@selector(doConfirm) forControlEvents:UIControlEventTouchUpInside];
            btnRepayment.tag = 21;
            [cell addSubview:btnRepayment];
            
        }
        
        return cell;
    }else{
        return nil;
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 150;
    }else{
        return 44;
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
    if (indexPath.section == 0 && indexPath.row < _shoppingRedPacketArr.count) {
        [self handleSelectedStatus:indexPath];
    }
}

#pragma mark - 按钮响应

- (void)back
{
    [AppUtils goBack:self];
}

- (IBAction)back:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(shoppingDeduction:totalValue:)]) {
        [self.delegate shoppingDeduction:_selectedRedPacketArr totalValue:_deduction];
    }
    
    [self back];
}


- (void)doConfirm
{
    // 如果没有选择弹窗提醒
    if (_selectedRedPacketArr.count == 0) {
        [AppUtils showLoadInfo:@"没有选择红包"];
        return;
    }else{
        if([self.delegate respondsToSelector:@selector(shoppingDeduction:totalValue:)]) {
            [self.delegate shoppingDeduction:_selectedRedPacketArr totalValue:_deduction];
        }
    }
    
    [self back];
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
