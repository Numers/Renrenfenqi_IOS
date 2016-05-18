//
//  MyJobsViewController2.m
//  renrenfenqi
//
//  Created by DY on 15/2/7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "MyJobsViewController2.h"
#import "CommonTools.h"
#import "CommonVariable.h"
#import "LDProgressView.h"
#import "OnlyPartTimeViewController.h"
#import "MyJobsTableViewCell2.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "JobDetailViewController2.h"
#import "UnusualView.h"
#import "MJRefresh.h"

@interface MyJobsViewController2 ()
{
    float  _parttimeDayViewHeight;
    CGSize _mainScreenSize;
    BOOL   _isPartTime;
    float  _surplusPartTimeDay;
    float  _partTimeDays;
    
    NSMutableArray *_myJobArr;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *parttimeDayView; // 兼职购物玩家显示兼职天数信息
@property (strong, nonatomic) UITableView *jobsTableView;

@property (strong, nonatomic) UILabel *parttimeDayInfoLabel;
@property (strong, nonatomic) LDProgressView *progressView;
@property (strong, nonatomic) UnusualView *errorView; // 异常界面：无数据，无信号

@end

static NSString * cellIdentifiler = @"myJobCell";

@implementation MyJobsViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initViewData];
    // 初始化UI
    [self initUI];
    // 请求兼职天进度数据
//    [self requestParttimeDay];
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 下拉上拉刷新
- (void)setupRefresh {
    [self.jobsTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];
    [self.jobsTableView headerBeginRefreshing];
}

// 开始进入刷新状态
- (void)headerRereshing
{
    if (_myJobArr.count > 0) {
        [_myJobArr removeAllObjects];
    }
    
    [self requestParttimeDay];
}

#pragma mark 数据处理

// 本页数据初始化
- (void)initViewData {
    _parttimeDayViewHeight = 60.0f;
    _surplusPartTimeDay = 0;
    _partTimeDays = 0;
    _isPartTime = NO;
    _mainScreenSize = _MainScreenFrame.size;
    _myJobArr = [NSMutableArray array];
}

- (void)requestParttimeDay {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    NSDictionary *parameters = @{@"students_id":userId};
    
//    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_DAY] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleParttimeDay:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
//            [AppUtils hideLoadIng];
            [self.jobsTableView headerEndRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [AppUtils hideLoadIng];
        [self.jobsTableView headerEndRefreshing];
        self.errorView.picImage = [UIImage imageNamed:@"no_wifi@2x.png"];
        self.errorView.messageStr = @"请检查网络，下拉刷新！";
        [self.errorView refreshView];
        self.errorView.hidden = NO;
        [self refreshUI];
    }];
}

- (void)handleParttimeDay:(NSDictionary *)dic {
    _isPartTime = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"is_day"]] boolValue];
    if (_isPartTime) {
        _surplusPartTimeDay = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"day"]] floatValue];
        _partTimeDays = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"total_day"]] floatValue];
    }
    
    [self refreshUI];
    // 获取我的兼职申请列表
    [self requestMyjobs];
}

- (void)requestMyjobs {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    NSDictionary *parameters = @{@"uid":[NSString stringWithFormat:@"%@", userId]};
    
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, MY_JOBS_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleMyJobs:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
//        [AppUtils hideLoadIng];
        [self.jobsTableView headerEndRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [AppUtils hideLoadIng];
        [self.jobsTableView headerEndRefreshing];
        self.errorView.picImage = [UIImage imageNamed:@"no_wifi@2x.png"];
        self.errorView.messageStr = @"请检查网络，下拉刷新！";
        [self.errorView refreshView];
        self.errorView.hidden = NO;
//        [self refreshUI];
    }];
}

- (void)handleMyJobs:(NSDictionary *)dic {
    _myJobArr = [[dic objectForKey:@"data"] mutableCopy];
    
    if (_myJobArr.count < 1) {
        self.errorView.picImage = [UIImage imageNamed:@"nobill_body_background_n@2x.png"];
        self.errorView.messageStr = @"没有兼职申请信息";
        [self.errorView refreshView];
        self.errorView.hidden = NO;
    }else{
         self.errorView.hidden = YES;
        [self.jobsTableView reloadData];
    }
}

#pragma mark 界面创建

// 初始化界面
- (void)initUI {
    self.view.backgroundColor = [CommonVariable grayBackgroundColor];
    // 初始化导航界面
    [self initTopViewUI];
    // 初始化兼职剩余显示信息
    [self initParttimeDayViewUI];
    // 初始化我的兼职信息列表
    [self initJobTableViewUI];
    // 初始化异常数据界面
    [self initErrorViewUI];
}

// 初始化导航界面
- (void)initTopViewUI {
    self.topView = [CommonTools generateTopBarWiwhOnlyBackButton:self title:@"我的兼职" action:@selector(back:)];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    
    UIButton *onlyPartTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    onlyPartTimeButton.backgroundColor = [UIColor clearColor];
    onlyPartTimeButton.titleLabel.font = GENERAL_FONT14;
    [onlyPartTimeButton setTitleColor:[CommonVariable redFontColor] forState:UIControlStateNormal];
    [onlyPartTimeButton setTitle:@"去兼职" forState:UIControlStateNormal];
    [onlyPartTimeButton addTarget:self action:@selector(touchOnlyPartTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    CGSize textSize = [@"去兼职" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT14}];
    onlyPartTimeButton.frame = CGRectMake(self.topView.frame.size.width - (textSize.width + 30.0f), 20.0f, textSize.width + 30.0f, 44.0f);
    [self.topView addSubview:onlyPartTimeButton];
}

// 初始化兼职剩余显示信息
- (void)initParttimeDayViewUI {
    self.parttimeDayView = [[UIView alloc] init];
    self.parttimeDayView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, _mainScreenSize.width, _parttimeDayViewHeight);
    self.parttimeDayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.parttimeDayView];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [CommonVariable grayLineColor];
    topLine.frame = CGRectMake(0, 0, self.parttimeDayView.frame.size.width, 0.5f);
    [self.parttimeDayView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [CommonVariable grayLineColor];
    bottomLine.frame = CGRectMake(0, self.parttimeDayView.frame.size.height - 0.5f, self.parttimeDayView.frame.size.width, 0.5f);
    [self.parttimeDayView addSubview:bottomLine];
    
    self.parttimeDayInfoLabel = [[UILabel alloc] init];
    self.parttimeDayInfoLabel.font = GENERAL_FONT13;
    self.parttimeDayInfoLabel.textColor = UIColorFromRGB(0x787878);
    self.parttimeDayInfoLabel.textAlignment = NSTextAlignmentCenter;
    CGSize textSize = [@"您还需要兼职：" sizeWithAttributes:@{NSFontAttributeName:self.parttimeDayInfoLabel.font}];
    self.parttimeDayInfoLabel.frame = CGRectMake(15.0f, 8.0f, self.parttimeDayView.frame.size.width - 30.0f, textSize.height);
    [self.parttimeDayView addSubview:self.parttimeDayInfoLabel];
    
    self.progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(35.0f, 28.0f, self.parttimeDayView.frame.size.width-70, 15.0f)];
    [self.progressView overrideProgressTextColor:UIColorFromRGB(0xa2a2a2)];
    self.progressView.color = UIColorFromRGB(0x6fd865);
    self.progressView.background = UIColorFromRGB(0xf9f0f1);
    self.progressView.flat = @YES;
    self.progressView.showBackgroundInnerShadow = @NO;
    self.progressView.animate = @YES;
    self.progressView.animateDirection = LDAnimateDirectionForward;
    [self.parttimeDayView addSubview:self.progressView];
}

// 初始化我的兼职信息列表
- (void)initJobTableViewUI {
    float yoffset = self.topView.frame.origin.y + self.topView.frame.size.height;
    self.jobsTableView = [[UITableView alloc] init];
    self.jobsTableView.backgroundColor = self.view.backgroundColor;
    self.jobsTableView.frame = CGRectMake(0, yoffset, _mainScreenSize.width, _mainScreenSize.height - yoffset);
    [self.view addSubview:self.jobsTableView];
    
    self.jobsTableView.delegate = self;
    self.jobsTableView.dataSource = self;
    
    self.jobsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.jobsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.jobsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.jobsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.jobsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

// 初始化异常界面
- (void)initErrorViewUI {
    // 创建空白数据界面
    CGRect errorViewFrame = CGRectMake(0, 0, self.jobsTableView.frame.size.width, self.jobsTableView.frame.size.height);
    self.errorView = [[UnusualView alloc] initWithFrame:errorViewFrame];
    self.errorView.hidden = YES;
    [self.jobsTableView addSubview:self.errorView];
}

- (void)refreshUI {
    float yoffset = self.topView.frame.origin.y + self.topView.frame.size.height;
    if (_isPartTime) {
        self.parttimeDayView.hidden = NO;
        self.parttimeDayInfoLabel.text = [NSString stringWithFormat:@"您还需要兼职：%0.2f天", _surplusPartTimeDay];
        self.progressView.progress = (_partTimeDays - _surplusPartTimeDay)/_partTimeDays;
        [self.progressView overrideProgressText:[NSString stringWithFormat:@"剩余%.0f%%", _surplusPartTimeDay/_partTimeDays * 100]];
        yoffset = self.parttimeDayView.frame.origin.y + self.parttimeDayView.frame.size.height + 10.0f;
    }else{
        self.parttimeDayView.hidden = YES;
    }
    
    self.jobsTableView.frame = CGRectMake(0, yoffset, _mainScreenSize.width, _mainScreenSize.height - yoffset);
}

#pragma mark UITableView Delegate

// 计算评论内容的cell 高度
- (int)calculateCellHeight:(NSString *)commentStr {
    int temp = 65.0f;
    if ([AppUtils isNullStr:commentStr]) {
        return temp;
    }
    
    CGSize maxContentSize = CGSizeMake(_mainScreenSize.width - 30.0f, 800.0f);
    CGSize commentSize = [commentStr boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:GENERAL_FONT14} context:nil].size;
    if (commentSize.height > 14.0f) {
        temp = ceilf(commentSize.height) + 65.0f + 40;
    }
    return temp;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_myJobArr.count <= indexPath.row) {
        return 0;
    }
    NSString *info = [[_myJobArr objectAtIndex:indexPath.row] objectForKey:@"state_info"];
    if ([AppUtils isNullStr:info]) {
        return 65.0f;
    }else{
        return [self calculateCellHeight:info];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= _myJobArr.count) {
        return;
    }
    
    JobDetailViewController2 *vc = [[JobDetailViewController2 alloc] init];
    vc.jobId = [NSString stringWithFormat:@"%@", [[_myJobArr objectAtIndex:indexPath.row] objectForKey:@"job_id"]];
    [AppUtils pushPage:self targetVC:vc];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return _myJobArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyJobsTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler];
    if (!cell) {
        cell = [[MyJobsTableViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiler];
    }
    
    if (_myJobArr.count <= indexPath.row) {
        return cell;
    }
    
    [cell myJobsData:[_myJobArr objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)touchOnlyPartTimeButton:(UIButton *)sender {
    OnlyPartTimeViewController *vc = [[OnlyPartTimeViewController alloc] init];
    [AppUtils pushPage:self targetVC:vc];
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
