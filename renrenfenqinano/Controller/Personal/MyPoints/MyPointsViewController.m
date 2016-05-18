//
//  MyPointsViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyPointsViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "OrderAddressAddViewController.h"
#import "MyOrdersViewController.h"

#import "TakeRedPacketView.h"
#import "RedPacketViewController.h"
#import "PersonalInfoViewController.h"

@interface MyPointsViewController ()
{
    NSArray *_infoArr; // 任务数据容器
    
    float _viewWidth;
    float _viewHeight;
    BOOL  _isAddress;
    BOOL  _isAuthentication;
    int   _myPoints;
}

@end

@implementation MyPointsViewController

static NSString *cellIdentifiler = @"Cell";
static NSString *infoIdentifiler = @"MyPointIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewData];
    
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:UPDATE_AUTH_INFO object:nil];
    
    // 设置关于信息栏圆角
//    self.aboutView.layer.cornerRadius = 5;
//    self.aboutView.layer.masksToBounds = YES;
    
    self.taskTableVIew.delegate = self;
    self.taskTableVIew.dataSource = self;
    self.taskTableVIew.scrollEnabled = YES;
    self.taskTableVIew.bounces = NO;
    
    [self.taskTableVIew registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.taskTableVIew respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.taskTableVIew setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.taskTableVIew respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.taskTableVIew setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //向服务器获取我的积分
    [self getMyPointsFromAPI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo{
    [self getMyPointsFromAPI];
}

#pragma mark - 数据处理
- (void)initViewData
{
    _infoArr = @[@"完善收货地址（可获得50积分）",@"学生认证（可获得200积分）",@"评价商品（可获得10积分）",@"积分使用规则"];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
}

// 获取积分接口
- (void)getMyPointsFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid": userId};
    
    [AppUtils showLoadIng:@""];
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, MY_POINTS] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];

        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            [AppUtils showLoadInfo:@""];
            
            NSString *mypoints = [[jsonData objectForKey:@"data"] objectForKey:@"stu_jf"];
            
            if ([AppUtils judgeStrIsEmpty:mypoints] ) {
                mypoints = @"0";
            }
            NSString *address = [[jsonData objectForKey:@"data"] objectForKey:@"stu_zl"];
            if ([AppUtils judgeStrIsEmpty:address] ) {
                address = @"0";
            }
            NSString *auth = [[jsonData objectForKey:@"data"] objectForKey:@"stu_rz"];
            if ([AppUtils judgeStrIsEmpty:auth] ) {
                auth = @"0";
            }
            
            _myPoints = [mypoints intValue];
            self.myPointsLabel.text = [NSString stringWithFormat:@"当前积分：%d",_myPoints];
            
            _isAddress = [address boolValue];
            _isAuthentication = [auth boolValue];
            
            [self.taskTableVIew reloadData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _infoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoIdentifiler forIndexPath:indexPath];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
        
        if (_infoArr.count <= indexPath.row) {
            return cell;
        }
        
        UILabel *contentLabel = (UILabel *)[cell viewWithTag:10];
        if (nil == contentLabel) {
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.frame.size.width - 30, 44)];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.font = GENERAL_FONT13;
            contentLabel.textColor = UIColorFromRGB(0x000000);;
            contentLabel.numberOfLines = 1;
            contentLabel.tag = 10;
            [cell addSubview:contentLabel];
        }
        
        UIImageView *imgSelectedStatus = (UIImageView *)[cell viewWithTag:11];
        if (imgSelectedStatus == nil) {
            imgSelectedStatus = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 46.0, 10.5, 23.0, 23.0)];
            imgSelectedStatus.image = [UIImage imageNamed:@"home_body_button_h@2x.png"];
            imgSelectedStatus.tag = 11;
            [cell addSubview:imgSelectedStatus];
        }
        
        contentLabel.text = _infoArr[indexPath.row];
        
        imgSelectedStatus.hidden = YES;
        if ((indexPath.row==0 && _isAddress) ||(indexPath.row==1 && _isAuthentication)) {
            imgSelectedStatus.hidden = NO;
        }
        
        return cell;
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 400;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ((indexPath.row==0 && _isAddress) ||(indexPath.row==1 && _isAuthentication)) {
         cell.accessoryType = UITableViewCellAccessoryNone;
    }else if (indexPath.row == 3){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
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
    
    if (indexPath.row == 0) {
        
        if (_isAddress) {
            [AppUtils showLoadInfo:@"完善收获地址已完成"];
        }else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OrderAddressAddViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"OrderAddressAddIdentifier"];
            vc.isNeedJudge = YES;
            [AppUtils pushPage:self targetVC:vc];
        }
        
    }else if (indexPath.row == 1){
        if (_isAuthentication) {
            [AppUtils showLoadInfo:@"学生认证已完成"];
        }else{
            PersonalInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalInfoIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }
        
    }else if (indexPath.row == 2){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyOrdersViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MyOrdersIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }
}

#pragma mark - 按钮响应

- (void)back
{
    [AppUtils goBack:self];
}

- (IBAction)back:(UIButton *)sender
{
    [self back];
}

// 点击积分抽取红包
- (IBAction)takeRedEnvelope:(UIButton *)sender
{
    if (_myPoints < 100) {
        [AppUtils showLoadInfo:@"您的积分不够100，加油赚积分哦"];
    }else{
        TakeRedPacketView *view = [[TakeRedPacketView alloc] initWithView:self.view.frame];
        [view show];
        
        view.dismissBlock = ^(){
            [self getMyPointsFromAPI];
        };
        
        view.lookMyRedPacketBlock = ^(){
            [UIView transitionWithView:self.navigationController.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                
                                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                                UIViewController *rootViewer = [viewControllers objectAtIndex:0];
                                [viewControllers removeAllObjects];
                                [viewControllers addObject:rootViewer];
                                
                                RedPacketViewController *redPacketVC = [self.storyboard  instantiateViewControllerWithIdentifier:@"RedPacketIdentifier"];
                                redPacketVC.hidesBottomBarWhenPushed = YES;
                                [viewControllers addObject:redPacketVC];
                                [self.navigationController setViewControllers:viewControllers animated:NO];
                                
                            }
                            completion:NULL];
        };

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
