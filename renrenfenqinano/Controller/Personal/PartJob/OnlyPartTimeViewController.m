//
//  OnlyPartTimeViewController.m
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "OnlyPartTimeViewController.h"
#import "OnlyPartTimeTableViewCell.h"
#import "CommonTools.h"
#import "UserLoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "UnusualView.h"
#import "JobDetailViewController2.h"
#import "CommonVariable.h"
#import "ImprovePersonalInfoViewController.h"
#import "ImprovePersonalInfoViewController2.h"

@interface OnlyPartTimeViewController ()
{
    NSMutableArray *_jobArr;
    NSMutableArray *_addressInfoArr;
    UIStoryboard   *_mainStoryboard;
    UIColor        *_backgroundColor;
    CGSize          _mainScreenSize;
    CGSize          _buttonSize;
    float           _menuViewHeight;
    BOOL            _isHeadRefresh;
    int             _pageIndex;
    
    NSMutableDictionary *_myjobSetting;
    UIStoryboard *_secondStorybord;
}

@property (strong, nonatomic) UIView      *topView;
@property (strong, nonatomic) UITableView *jobTableView;

@property (strong, nonatomic) UIView   *menuView;  // 登录提醒背景
@property (strong, nonatomic) UILabel  *textLabel; // 提示登录
@property (strong, nonatomic) UIButton *loginBtn;  // 登录按钮

@property (strong, nonatomic) UnusualView *errorView; // 异常界面：无数据，无信号

@end

static NSString * cellIdentifiler = @"onlyPartTimeCell";

@implementation OnlyPartTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOnlyParttimeData) name:UPDATE_ONLY_PARTTIME_DATA object:nil];
    // 初始化本界面数据
    [self initViewData];
    // 初始化本界面UI布局
    [self initUI];
    // 设置上拉加载更多，下拉刷新
    [self setupRefresh];
    // 刷新数据
    [self reloadOnlyParttimeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

- (void)reloadOnlyParttimeData {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    if ([AppUtils isLogined:userId]) {
        [self requestParttimeInfo:userId];
    }else{
        self.buttonTag = USER_STATUS_NOT_LOGIN;
        [self refreshUI];
        [self.jobTableView headerBeginRefreshing];
    }
}

- (void)initViewData {
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _jobArr = [NSMutableArray array];
    _addressInfoArr = [NSMutableArray array];
    _menuViewHeight = 40.0f;
    _backgroundColor = [CommonVariable grayBackgroundColor];
    _mainScreenSize = _MainScreenFrame.size;
    _buttonSize = CGSizeMake(80.0f, 25.0f);
    _pageIndex = 1;
    _myjobSetting = [NSMutableDictionary dictionary];
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
}

- (NSString *)buttonText:(ButtonTag)buttonTag {
    NSString *temp = @"";
    if (buttonTag == USER_STATUS_NOT_LOGIN) {
        temp = @"登录之后，职位推荐更精准！";
    }else if (buttonTag == USER_STATUS_NOT_FINISH_FIRST || buttonTag == USER_STATUS_NOT_FINISH_SECOND) {
        temp = @"完善资料，职位推荐更精准！";
    }
    
    return temp;
}

- (void)initUI {
    self.view.backgroundColor = [CommonVariable grayBackgroundColor];
    self.topView = [CommonTools generateTopBarWiwhOnlyBackButton:self title:@"只想兼职" action:@selector(back:)];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    
    self.menuView = [[UIView alloc] init];
    self.menuView.backgroundColor = [CommonVariable redBackgroundColor];
    self.menuView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, _mainScreenSize.width, _menuViewHeight);
    [self.view addSubview:self.menuView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.frame = CGRectMake(20.0f, 0, 200.0f, self.menuView.frame.size.height);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.font = GENERAL_FONT14;
    self.textLabel.textColor = UIColorFromRGB(0xffffff);
    [self.menuView addSubview:self.textLabel];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.frame = CGRectMake(_mainScreenSize.width - 15.0f - _buttonSize.width, 0.5*(self.menuView.frame.size.height - _buttonSize.height), _buttonSize.width, _buttonSize.height);

    [self.loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.loginBtn];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [CommonVariable grayLineColor];
    line.frame = CGRectMake(0, self.menuView.frame.size.height - 0.5f, _mainScreenSize.width, 0.5f);
    [self.menuView addSubview:line];
    self.menuView.hidden = YES;
    
    float yOffset = self.topView.frame.origin.y + self.topView.frame.size.height;
    self.jobTableView = [[UITableView alloc] init];
    self.jobTableView.backgroundColor = _backgroundColor;
    self.jobTableView.frame = CGRectMake(0, yOffset, _mainScreenSize.width, _mainScreenSize.height - yOffset);
    [self.view addSubview:self.jobTableView];
    
    self.jobTableView.delegate = self;
    self.jobTableView.dataSource = self;
    
    self.jobTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.jobTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.jobTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.jobTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.jobTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.errorView = [[UnusualView alloc] initWithFrame:CGRectMake(0, 0, self.jobTableView.frame.size.width, self.jobTableView.frame.size.height)];
    self.errorView.hidden = YES;
    [self.jobTableView addSubview:self.errorView];
}

- (void)refreshUI {
    
    float yOffset = self.menuView.frame.origin.y + self.menuView.frame.size.height;
    if (self.buttonTag == USER_STATUS_NOT_LOGIN) {
        self.menuView.hidden = NO;
        self.textLabel.text = [self buttonText:self.buttonTag];
        [self.loginBtn setImage:[UIImage imageNamed:@"justwork_body_login_n.png"] forState:UIControlStateNormal];
        
    }else if (self.buttonTag == USER_STATUS_ALL_FINISH) {
        self.menuView.hidden = YES;
        yOffset = self.topView.frame.origin.y + self.topView.frame.size.height;
    }else {
        self.menuView.hidden = NO;
        self.textLabel.text = [self buttonText:self.buttonTag];
        [self.loginBtn setImage:[UIImage imageNamed:@"justwork_body_perfectinformation_n.png"] forState:UIControlStateNormal];
    }
    
    self.jobTableView.frame = CGRectMake(0, yOffset, _mainScreenSize.width, _mainScreenSize.height - yOffset);
    self.errorView.frame = CGRectMake(0, 0, self.jobTableView.frame.size.width, self.jobTableView.frame.size.height);
}

// 集成刷新控件
- (void)setupRefresh {
    [self.jobTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];

    [self.jobTableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

- (void)headerRereshing {
    _isHeadRefresh = YES;
    [_jobArr removeAllObjects];
    _pageIndex = 1;
    [self requestJobsList:_pageIndex];
}

- (void)footerRereshing {
    _isHeadRefresh = NO;
    _pageIndex++;
    [self requestJobsList:_pageIndex];
}

#pragma mark 数据处理

- (void)requestParttimeInfo:(NSString *)userId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId};
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _myjobSetting = [jsonData objectForKey:@"data"];
            
            if ([[_myjobSetting objectForKey:@"is_info"] intValue] == 0) {
                self.buttonTag = USER_STATUS_NOT_FINISH_FIRST;
            }else if ([[_myjobSetting objectForKey:@"state"] intValue] == 0) {
                self.buttonTag = USER_STATUS_NOT_FINISH_SECOND;
            }else {
                self.buttonTag = USER_STATUS_ALL_FINISH;
            }
            
            self.errorView.hidden = YES;
            [self refreshUI];
            [self.jobTableView headerBeginRefreshing];
        }else{
            self.errorView.hidden = YES;
            self.buttonTag = USER_STATUS_NOT_FINISH_FIRST;
            [self refreshUI];
            [self.jobTableView headerBeginRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.errorView.hidden = NO;
        self.errorView.picImage = [UIImage imageNamed:@"no_wifi@2x.png"];
        self.errorView.messageStr = @"请检查网络，下拉刷新！";
        [self.errorView refreshView];
    }];
}

- (void)requestJobsList:(int)pageIndex {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *currentCity = [app.store getStringById:USER_CITY fromTable:USER_TABLE];
    NSString *currentArea = [app.store getStringById:USER_AREA fromTable:USER_TABLE];
    if ([AppUtils isNullStr:currentCity]) {
        currentCity = @"";
    }else{
        currentCity = [currentCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
    }
    if ([AppUtils isNullStr:currentArea]) {
        currentArea = @"";
    }else{
        currentArea = [currentArea stringByReplacingOccurrencesOfString:@"区" withString:@""];
    }
    
    NSDictionary *parameters = @{@"uid":[AppUtils filterNull:userId],
                                 @"city":currentCity,
                                 @"area":currentArea,
                                 @"page":[NSString stringWithFormat:@"%d", pageIndex]
                                 };
    
    [manager GET:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_JOBS_DATA] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleRequestJobsList:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
            if (_pageIndex > 0) {
                _pageIndex--;
            }
        }
        
        [self endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self endRefreshing];
        self.errorView.picImage = [UIImage imageNamed:@"no_wifi@2x.png"];
        self.errorView.messageStr = @"请检查网络，下拉刷新！";
        [self.errorView refreshView];
        self.errorView.hidden = NO;
        if (_pageIndex > 0) {
            _pageIndex--;
        }
    }];
}

- (void)endRefreshing {
    if (_isHeadRefresh) {
        [self.jobTableView headerEndRefreshing];
    }else{
        [self.jobTableView footerEndRefreshing];
    }
}

- (void)handleRequestJobsList:(NSDictionary *)dic {
    NSArray *tempArr = [[dic objectForKey:@"list"] mutableCopy];
    [_jobArr addObjectsFromArray:tempArr];
    if (_jobArr.count == 0) {
        self.errorView.picImage = [UIImage imageNamed:@"nobill_body_background_n@2x.png"];
        self.errorView.messageStr = @"没有兼职信息";
        [self.errorView refreshView];
        self.errorView.hidden = NO;
    }else{
        if (tempArr.count == 0) {
            [AppUtils showLoadInfo:@"没有更多数据可加载"];
        }else{
            self.errorView.hidden = YES;
            [self.jobTableView reloadData];
        }
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
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
    
    if (indexPath.row >= _jobArr.count) {
        return;
    }
    
    JobDetailViewController2 *vc = [[JobDetailViewController2 alloc] init];
    vc.jobId = [NSString stringWithFormat:@"%@", [[_jobArr objectAtIndex:indexPath.row] objectForKey:@"id"]];
    [AppUtils pushPage:self targetVC:vc];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return _jobArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OnlyPartTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler];
    if (!cell) {
        cell = [[OnlyPartTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiler];
    }
    
    if (_jobArr.count <= indexPath.row) {
        return cell;
    }
    
    [cell jobsData:[_jobArr objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)login:(UIButton *)sender {
    if (self.buttonTag == USER_STATUS_NOT_LOGIN) {
        UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        vc.writeInfoMode = WriteInfoModeNone;
        vc.parentClass = [OnlyPartTimeViewController class];
        [AppUtils pushPageFromBottomToTop:self targetVC:vc];
    }else if (self.buttonTag == USER_STATUS_NOT_FINISH_FIRST) {
        ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
        vc.isSkip = NO;
        vc.theViewClass = [OnlyPartTimeViewController class];
        [AppUtils pushPage:self targetVC:vc];
    }else if (self.buttonTag == USER_STATUS_NOT_FINISH_SECOND) {
        ImprovePersonalInfoViewController2 *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
        vc.theViewClass = [OnlyPartTimeViewController class];
        [AppUtils pushPage:self targetVC:vc];
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
