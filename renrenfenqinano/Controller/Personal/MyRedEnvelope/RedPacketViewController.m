//
//  RedPacketViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/22.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "RedPacketViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "MyBillsViewController.h"

#import "CommonWebViewController.h"

@interface RedPacketViewController ()
{
    NSMutableArray *_shoppingRedPacketArr; // 购物红包容器
    NSMutableArray *_repaymentRedPacketArr;// 还款红包容器
    
    float _viewWidth; // 屏幕尺寸宽度
    float _viewHeight;// 频幕尺寸高度
    
    NSDictionary *_billInfoDic; // 账单信息和是否设置代扣
}

@property (nonatomic, strong) UILabel *tipsLabel; // 没有数据提示label
@property (assign, nonatomic) RedPacketStatus redPacketStatusSelected; // 存储选择类型红包
@property (strong, nonatomic) UIButton *rePayBtn;

@end

@implementation RedPacketViewController

static NSString *notUsedCellIdentifiler = @"notUsedCell"; //没有使用的红包cell
static NSString *usedCellIdentifiler = @"usedCell";       //已经使用的红包cell
static NSString *overdueCellIdentifiler = @"overdueCell"; //过期的红包cell
static NSString *cellIdentifiler = @"Cell";               //按钮和标题动态变化的cell

static NSString *cellIdentifiler1 = @"Cell1";             // 没有红包cell

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化本界面所用的数据
    [self initViewData];
    
    self.redPacketList.delegate = self;
    self.redPacketList.dataSource = self;
    self.redPacketList.backgroundColor = [UIColor clearColor];
    // IOS7 以上支持， 作用：隐藏无数据情况下，cell的默认横线
    self.redPacketList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:notUsedCellIdentifiler];
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:usedCellIdentifiler];
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:overdueCellIdentifiler];
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    [self.redPacketList registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler1];
    
    if ([self.redPacketList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.redPacketList setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.redPacketList respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.redPacketList setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // 加载红包列表，默认加载未使用红包
    [self getRedPacketDetailFromAPI:self.redPacketStatusSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initViewData
{
    _shoppingRedPacketArr = [NSMutableArray array];
    _repaymentRedPacketArr = [NSMutableArray array];
    _billInfoDic = [NSDictionary dictionary];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    self.redPacketStatusSelected = RedPacketStatus_NotUsed;
}

#pragma mark 数据获取

- (void)getRedPacketDetailFromAPI:(int)status
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid":userId,
                                 @"type":@"",
                                 @"status":[NSString stringWithFormat:@"%d", status]};
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

// 处理获取红包数据，分类：1-购物红包，2-还款红包
- (void)handleRedPacketData:(NSArray *)result
{
    [_shoppingRedPacketArr removeAllObjects];
    [_repaymentRedPacketArr removeAllObjects];
    
    for (NSDictionary *data in result){
        int type = [[data objectForKey:@"type"] intValue];
        if (type == 1) {
            [_shoppingRedPacketArr  addObject:data];
        }else if (type == 2){
            [_repaymentRedPacketArr addObject:data];
        }
    }
    
    [self.redPacketList reloadData];
}

// 获取是否代扣+当前账单
- (void)getPersonalBillsAndCon
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    
    [AppUtils showLoadIng:@"获取账单信息"];
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, GET_BILL_AND_CON] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.rePayBtn.enabled = YES;
        
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleBillsAndConData:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        self.rePayBtn.enabled = YES;
    }];
}

// 处理是否代扣和当前账单
- (void)handleBillsAndConData:(NSDictionary *)dic
{
    _billInfoDic = [NSDictionary dictionaryWithDictionary:dic];
    
    float cal_repayment_money = [[[_billInfoDic objectForKey:@"now"] objectForKey:@"cal_repayment_money"] floatValue];
    
    if (cal_repayment_money > 0) {
        if ([[_billInfoDic objectForKey:@"contract"] intValue] == 1) {
            DeductionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DeductionIdentifier"];
            vc.delegate = self;
            vc.billDic = _billInfoDic;
            [AppUtils pushPage:self targetVC:vc];
        }else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyBillsViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MyBillsIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }
    }else{
        [AppUtils showLoadInfo:@"本月还款账单已全清"];
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 44;
        case 1:
            if (self.redPacketStatusSelected == RedPacketStatus_NotUsed && _repaymentRedPacketArr.count > 0) {
                return 95;
            }else{
                return 30;
            }
        case 2:
            return 44;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex) {
        case 0:
            return _repaymentRedPacketArr.count == 0 ? 1:_repaymentRedPacketArr.count;
        case 1:
            return 1;
        case 2:
            return _shoppingRedPacketArr.count == 0 ? 1:_shoppingRedPacketArr.count;
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
            UITableViewCell *cell;
            if (_repaymentRedPacketArr.count == 0) {
               cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler1 forIndexPath:indexPath];
                
                self.tipsLabel = (UILabel *)[cell viewWithTag:101];
                if (nil == self.tipsLabel) {
                    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _viewWidth - 30, 44)];
                    self.tipsLabel.font = GENERAL_FONT13;
                    self.tipsLabel.textColor = [UIColor blackColor];
                    self.tipsLabel.numberOfLines = 1;
                    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
                    self.tipsLabel.tag = 101;
                    [cell addSubview:self.tipsLabel];
                }
                
                self.tipsLabel.text = @"没有还款红包";
                
                return cell;
            }else{
                
                if (self.redPacketStatusSelected == RedPacketStatus_Used) {
                    cell = [tableView dequeueReusableCellWithIdentifier:usedCellIdentifiler forIndexPath:indexPath];
                }else if (self.redPacketStatusSelected == RedPacketStatus_Overdue){
                    cell = [tableView dequeueReusableCellWithIdentifier:overdueCellIdentifiler forIndexPath:indexPath];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:notUsedCellIdentifiler forIndexPath:indexPath];
                }
                
                NSDictionary *dataDic = [NSDictionary dictionary];
                
                if (_repaymentRedPacketArr.count <= indexPath.row) {
                    return cell;
                }
                dataDic = _repaymentRedPacketArr[indexPath.row];
                
                UIImageView *imgRedPacket = (UIImageView *)[cell viewWithTag:10];
                if (imgRedPacket == nil) {
                    imgRedPacket = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 14.0, 23.0, 17.0)];
                    imgRedPacket.image = [UIImage imageNamed:@"home_body_redenvelopes_n@2x.png"];
                    imgRedPacket.tag = 10;
                    [cell addSubview:imgRedPacket];
                }
                
                UIImageView *imgRedPacketFailure = (UIImageView *)[cell viewWithTag:11];
                if (imgRedPacketFailure == nil) {
                    imgRedPacketFailure = [[UIImageView alloc] initWithFrame:CGRectMake(130.0, 1.5, 41.0, 41.0)];
                    imgRedPacketFailure.image = [UIImage imageNamed:@"redenvelopes_body_postmark_h@2x.png"];
                    imgRedPacketFailure.tag = 11;
                    [cell addSubview:imgRedPacketFailure];
                }
                
                UILabel *redMoney = (UILabel *)[cell viewWithTag:12];
                if (redMoney == nil) {
                    redMoney = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 0, 70.0, 44.0)];
                    redMoney.font = GENERAL_FONT13;
                    redMoney.numberOfLines = 1;
                    redMoney.textAlignment = NSTextAlignmentLeft;
                    redMoney.tag = 12;
                    [cell addSubview:redMoney];
                }
                
                UILabel *redPacketInfoLabel = (UILabel *)[cell viewWithTag:13];
                if (redPacketInfoLabel == nil) {
                    redPacketInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(115.0f, 0, self.view.bounds.size.width - 112.0f, 44.0f)];
                    redPacketInfoLabel.font = GENERAL_FONT13;
                    redPacketInfoLabel.textColor = UIColorFromRGB(0x000000);
                    redPacketInfoLabel.numberOfLines = 1;
                    redPacketInfoLabel.textAlignment = NSTextAlignmentLeft;
                    redPacketInfoLabel.tag = 13;
                    [cell addSubview:redPacketInfoLabel];
                }
                
                redMoney.text = [NSString stringWithFormat:@"%@元红包",[dataDic objectForKey:@"red_money"]];
                
                if (self.redPacketStatusSelected == RedPacketStatus_NotUsed || self.redPacketStatusSelected == RedPacketStatus_Overdue) {
                    
                    NSString *createTime = [dataDic objectForKey:@"create_time"];
                    createTime = [[createTime substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                    NSString *expireTime = [dataDic objectForKey:@"expire_time"];
                    expireTime = [[expireTime substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                    redPacketInfoLabel.text = [NSString stringWithFormat:@"有效期   %@-%@",createTime,expireTime];
                    
                    if (self.redPacketStatusSelected == RedPacketStatus_Overdue) {
                        imgRedPacketFailure.hidden = NO;
                        redPacketInfoLabel.textColor = UIColorFromRGB(0xa2a2a2);
                    }else{
                        imgRedPacketFailure.hidden = YES;
                        redPacketInfoLabel.textColor = UIColorFromRGB(0x000000);
                    }
                    
                }else if (self.redPacketStatusSelected == RedPacketStatus_Used){
                    NSString *useTime = [dataDic objectForKey:@"use_time"];
                    redPacketInfoLabel.text = [NSString stringWithFormat:@"使用日期  %@",useTime];
                    
                    imgRedPacketFailure.hidden = YES;
                }
                
                return cell;

            }
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
  
            self.rePayBtn = (UIButton *)[cell viewWithTag:20];
            if (self.rePayBtn == nil) {
                self.rePayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                self.rePayBtn.backgroundColor = [UIColor clearColor];
                self.rePayBtn.frame = CGRectMake(10.0, 10.0, _viewWidth - 20, 35);
                [self.rePayBtn setImage:[UIImage imageNamed:@"redenvelopes_body_repayment_n@2x.png.png"] forState:UIControlStateNormal];
                [self.rePayBtn addTarget:self action:@selector(doRepayment) forControlEvents:UIControlEventTouchUpInside];
                self.rePayBtn.tag = 20;
                [cell addSubview:self.rePayBtn];
            }
            
            UIView *line = (UIView *)[cell viewWithTag:21];
            if (line == nil) {
                line = [[UIView alloc] initWithFrame:CGRectMake(0, 65, _viewWidth, 0.5)];
                line.backgroundColor = UIColorFromRGB(0xe0e0e0);
                line.tag = 21;
                [cell addSubview:line];
            }
            
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:22];
            if (lblTitle == nil) {
                lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 66, 52, 30)];
                lblTitle.backgroundColor = [UIColor clearColor];
                lblTitle.text = @"购物红包";
                lblTitle.textColor = [UIColor blackColor];
                lblTitle.font = GENERAL_FONT13;
                lblTitle.numberOfLines = 1;
                lblTitle.textAlignment = NSTextAlignmentLeft;
                lblTitle.tag = 22;
                [cell addSubview:lblTitle];
            }
            
            if (self.redPacketStatusSelected == RedPacketStatus_NotUsed && _repaymentRedPacketArr.count > 0) {
                self.rePayBtn.hidden = NO;
                lblTitle.frame = CGRectMake(15, 66, 52, 30);
                line.hidden = NO;
            }else{
                self.rePayBtn.hidden = YES;
                lblTitle.frame = CGRectMake(15, 0, 52, 30);
                line.hidden = YES;
            }
            
            return cell;
        }
        case 2:
        {
            UITableViewCell *cell;
            if (_shoppingRedPacketArr.count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler1 forIndexPath:indexPath];
                
                self.tipsLabel = (UILabel *)[cell viewWithTag:101];
                if (nil == self.tipsLabel) {
                    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _viewWidth - 30, 44)];
                    self.tipsLabel.font = GENERAL_FONT13;
                    self.tipsLabel.textColor = [UIColor blackColor];
                    self.tipsLabel.numberOfLines = 1;
                    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
                    self.tipsLabel.tag = 101;
                    [cell addSubview:self.tipsLabel];
                }
                
                self.tipsLabel.text = @"没有购物红包";
                
                return cell;
            }else{
                if (self.redPacketStatusSelected == RedPacketStatus_Used) {
                    cell = [tableView dequeueReusableCellWithIdentifier:usedCellIdentifiler forIndexPath:indexPath];
                }else if (self.redPacketStatusSelected == RedPacketStatus_Overdue){
                    cell = [tableView dequeueReusableCellWithIdentifier:overdueCellIdentifiler forIndexPath:indexPath];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:notUsedCellIdentifiler forIndexPath:indexPath];
                }
                
                NSDictionary *dataDic = [NSDictionary dictionary];
                if (_shoppingRedPacketArr.count <= indexPath.row) {
                    return cell;
                }
                dataDic = _shoppingRedPacketArr[indexPath.row];
                
                UIImageView *imgRedPacket = (UIImageView *)[cell viewWithTag:10];
                if (imgRedPacket == nil) {
                    imgRedPacket = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 14.0, 23.0, 17.0)];
                    imgRedPacket.image = [UIImage imageNamed:@"home_body_redenvelopes_n@2x.png"];
                    imgRedPacket.tag = 10;
                    [cell addSubview:imgRedPacket];
                }
                
                UIImageView *imgRedPacketFailure = (UIImageView *)[cell viewWithTag:11];
                if (imgRedPacketFailure == nil) {
                    imgRedPacketFailure = [[UIImageView alloc] initWithFrame:CGRectMake(130.0, 1.5, 41.0, 41.0)];
                    imgRedPacketFailure.image = [UIImage imageNamed:@"redenvelopes_body_postmark_h@2x.png"];
                    imgRedPacketFailure.tag = 11;
                    [cell addSubview:imgRedPacketFailure];
                }
                
                UILabel *redMoney = (UILabel *)[cell viewWithTag:12];
                if (redMoney == nil) {
                    redMoney = [[UILabel alloc] initWithFrame:CGRectMake(42.0, 0, 70.0, 44.0)];
                    redMoney.font = GENERAL_FONT13;
                    redMoney.numberOfLines = 1;
                    redMoney.textAlignment = NSTextAlignmentLeft;
                    redMoney.tag = 12;
                    [cell addSubview:redMoney];
                }
                
                UILabel *redPacketInfoLabel = (UILabel *)[cell viewWithTag:13];
                if (redPacketInfoLabel == nil) {
                    redPacketInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(112.0f, 0, self.view.bounds.size.width - 112.0f, 44.0f)];
                    redPacketInfoLabel.font = GENERAL_FONT13;
                    redPacketInfoLabel.textColor = UIColorFromRGB(0x000000);
                    redPacketInfoLabel.numberOfLines = 1;
                    redPacketInfoLabel.textAlignment = NSTextAlignmentLeft;
                    redPacketInfoLabel.tag = 13;
                    [cell addSubview:redPacketInfoLabel];
                }
                
                redMoney.text = [NSString stringWithFormat:@"%@元红包",[dataDic objectForKey:@"red_money"]];
                
                if (self.redPacketStatusSelected == RedPacketStatus_NotUsed || self.redPacketStatusSelected == RedPacketStatus_Overdue) {

                    NSString *createTime = [dataDic objectForKey:@"create_time"];
                    createTime = [[createTime substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                    NSString *expireTime = [dataDic objectForKey:@"expire_time"];
                    expireTime = [[expireTime substringToIndex:10] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                    redPacketInfoLabel.text = [NSString stringWithFormat:@"有效期   %@-%@",createTime,expireTime];
                    
                    if (self.redPacketStatusSelected == RedPacketStatus_Overdue) {
                        imgRedPacketFailure.hidden = NO;
                        redPacketInfoLabel.textColor = UIColorFromRGB(0xa2a2a2);
                    }else{
                        imgRedPacketFailure.hidden = YES;
                        redPacketInfoLabel.textColor = UIColorFromRGB(0x000000);
                    }
                    
                }else if (self.redPacketStatusSelected == RedPacketStatus_Used){
                    NSString *useTime = [dataDic objectForKey:@"use_time"];
                    redPacketInfoLabel.text = [NSString stringWithFormat:@"使用日期  %@",useTime];
                    
                    imgRedPacketFailure.hidden = YES;
                }
                
                return cell;

            }
        }
        default:
        {
            //            UITableViewCell *cell = [[UITableViewCell alloc] init];
            //            return cell;
            return nil;
        }
    }
}

#pragma mark 按钮响应

- (IBAction)back:(id)sender
{
    [AppUtils goBack:self];
}

// 查看红包规则界面
- (IBAction)useRule:(id)sender
{
    CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_RED_USE_ROLE;
    vc.titleString = @"红包使用规则";
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)redPacketSelected:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    
    switch (index) {
        case 0:
            self.redPacketStatusSelected = RedPacketStatus_NotUsed;
            break;
        case 1:
            self.redPacketStatusSelected = RedPacketStatus_Used;
            break;
        case 2:
            self.redPacketStatusSelected = RedPacketStatus_Overdue;
            break;
            
        default:
             self.redPacketStatusSelected = RedPacketStatus_All;
            break;
    }
    
    [self getRedPacketDetailFromAPI:self.redPacketStatusSelected];
}

-(void)doRepayment
{
    self.rePayBtn.enabled = NO;
    [self getPersonalBillsAndCon];
}

#pragma mark- DuductionDelegate
// 红包使用成功后重新刷新红包列表界面
- (void)deduction:(NSMutableArray *)redPakets
{
    if (redPakets.count == 0) {
        return;
    }
    
    for (NSString *usedRedId in redPakets){
        for (int index = 0; index < _repaymentRedPacketArr.count; index++) {
            if ([usedRedId isEqualToString:[[_repaymentRedPacketArr objectAtIndex:index] objectForKey:@"red_id"]]) {
                [_repaymentRedPacketArr removeObjectAtIndex:index];
            }
        }
    }
    
    [self.redPacketList reloadData];
}

@end
