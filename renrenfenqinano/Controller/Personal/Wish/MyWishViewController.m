//
//  MyWishViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyWishViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

#import "MyWishTableViewCell.h"
#import "MJRefresh.h"
#import "CommonTools.h"
#import "UnusualView.h"

@interface MyWishViewController ()
{
    NSMutableArray *_myWishArr;
}

@property (weak, nonatomic) IBOutlet UITableView *myWishTableView;

@property (strong, nonatomic) UnusualView *errorView; // 异常界面：无数据，无信号

@end

static NSString *cellIdentifiler = @"myWishCellIdentifier";

@implementation MyWishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myWishArr = [NSMutableArray array];
    
    self.myWishTableView.dataSource = self;
    self.myWishTableView.delegate = self;
    
    // IOS7 以上支持， 作用：隐藏无数据情况下，cell的默认横线
    self.myWishTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([self.myWishTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myWishTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.myWishTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myWishTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // 创建空白数据界面
    CGRect errorViewFrame = CGRectMake(0, 0, _MainScreen_Width, _MainScreen_Height - 65.0f);
    _errorView = [[UnusualView alloc] initWithFrame:errorViewFrame];
    _errorView.hidden = YES;
    [_myWishTableView addSubview:_errorView];
    
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 下拉上拉刷新
- (void)setupRefresh {
    
    [self.myWishTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];
    [self.myWishTableView headerBeginRefreshing];
    
    self.myWishTableView.headerPullToRefreshText = @"下拉可以刷新了";
    self.myWishTableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.myWishTableView.headerRefreshingText = @"仁仁分期玩命刷新中";
}

// 开始进入刷新状态
- (void)headerRereshing
{
    [_myWishArr removeAllObjects];
    [self getMyWIshList];
}

#pragma mark 数据处理
- (void)getMyWIshList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid":userId};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, GET_MY_WISH_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleMyWish:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        [self.myWishTableView headerEndRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        [self.myWishTableView headerEndRefreshing];
        _errorView.picImage = [UIImage imageNamed:@"no_wifi@2x.png"];
        _errorView.messageStr = @"请检查网络，重新刷新！";
        [_errorView refreshView];
        _errorView.hidden = NO;
    }];
}

- (void)handleMyWish:(NSDictionary *)dic {
     _myWishArr = [[dic objectForKey:@"data"] mutableCopy];
    if (_myWishArr.count == 0) {
        _errorView.picImage = [UIImage imageNamed:@"nobill_body_background_n@2x.png"];
        _errorView.messageStr = @"你还没提交过心愿哦！";
        [_errorView refreshView];
        _errorView.hidden = NO;
    }else{
        _errorView.hidden = YES;
        [_myWishTableView reloadData];
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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


#pragma mark UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _myWishArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyWishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    
    if (_myWishArr.count <= indexPath.row) {
        return cell;
    }
    
    [cell myWish:[_myWishArr objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
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
