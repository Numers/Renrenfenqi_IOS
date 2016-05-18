//
//  CommentViewController.m
//  renrenfenqi
//
//  Created by DY on 15/1/13.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CommentViewController.h"
#import "CommonTools.h"
#import "CommentTableViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "URLManager.h"

@interface CommentViewController ()
{
    NSMutableArray *_contentArr;
    NSDictionary *_userIfo;
    int  _pageIndex;
    int  _pageSize;
    NSString *_newCommentStr;
    BOOL _isHeadRefresh;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UITableView *contentTableView;

@end

static NSString * cellIdentifiler = @"commentCell";

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化数据
    [self initCommentViewData];
    // 创建头部导航界面
    [self createTopView];
    // 创建评论内容界面
    [self createcontentView];
    // 创建自定义界面
    [[CustomKeyboard customKeyboard]textViewShowView:self customKeyboardDelegate:self];
    // 下拉刷新上拉加载
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 集成刷新控件
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.contentTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];
    [self.contentTableView headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.contentTableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    _isHeadRefresh = YES;
    [_contentArr removeAllObjects];
    _pageIndex = 1;
    [self getCommentData:_pageIndex count:_pageSize];
}

- (void)footerRereshing
{
    _isHeadRefresh = NO;
    _pageIndex++;
    [self getCommentData:_pageIndex count:_pageSize];
}

#pragma mark 初始化数据
- (void)initCommentViewData {
    _contentArr = [NSMutableArray array];
    _pageIndex = 1;
    _pageSize = 20;
    _userIfo = [AppUtils getUserInfo];
    _newCommentStr = @"";
}

#pragma mark UI创建

// 创建top导航页面
- (void)createTopView {
    self.topView = [CommonTools generateTopBarWiwhOnlyTitle:self title:@"评论"];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    
    // 名为完成其实只是退出当前界面
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];
    okBtn.titleLabel.font = GENERAL_FONT15;
    [okBtn setTitleColor:UIColorFromRGB(0xfb6362) forState:UIControlStateNormal];
    okBtn.frame = CGRectMake(self.view.frame.size.width - 52, 20, 44, 44);
    [okBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:okBtn];
}

// 创建评论显示内容
- (void)createcontentView {
    self.contentTableView = [[UITableView alloc] init];
    self.contentTableView.backgroundColor = [UIColor clearColor];
    self.contentTableView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, _MainScreen_Width, _MainScreenFrame.size.height - (self.topView.frame.origin.y + self.topView.frame.size.height) - 50);
    
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;

    self.contentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.contentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.contentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.contentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.contentTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:self.contentTableView];
}

// 计算评论内容的cell 高度
- (int)calculateCellHeight:(NSString *)commentStr {
    int temp = 65;
    CGSize maxContentSize = CGSizeMake(_MainScreen_Width - 75.0f, 130.0f);
    CGSize commentSize = [commentStr boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:GENERAL_FONT14} context:nil].size;
    if (commentSize.height > 28) {
        temp = ceilf(commentSize.height) + 50;
    }
    return temp;
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_contentArr.count <= indexPath.row) {
        return 0;
    }
    
    NSString *commentStr = [AppUtils filterNull:[[_contentArr objectAtIndex:indexPath.row] objectForKey:@"content"]];
    
    return [self calculateCellHeight:commentStr];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == _contentArr.count -1) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return _contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler];
    if (!cell) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiler];
    }
    
    NSLog(@"count:%d, row:%d", (int)_contentArr.count, (int)indexPath.row);
    if (_contentArr.count <= indexPath.row) {
        return cell;
    }
    
    [cell commentData:[_contentArr objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 自定义键盘协议
-(void)sendComment:(NSString *)commentStr
{
    NSLog(@"%@",commentStr);
    _newCommentStr = commentStr;
    [self requestAddComment:_newCommentStr];
}

#pragma mark 数据处理
// 获取指定活动主题的评论
- (void)getCommentData:(int)pageIndex count:(int)pageSize {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"ac_id":self.activityID,
                                 @"page":[NSString stringWithFormat:@"%d", pageIndex],
                                 @"page_size":[NSString stringWithFormat:@"%d", pageSize]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, GET_COMMENTS_DATA] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
         if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleCommentData:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
        if (_isHeadRefresh) {
            [self.contentTableView headerEndRefreshing];
        }else{
            [self.contentTableView footerEndRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        if (_isHeadRefresh) {
            [self.contentTableView headerEndRefreshing];
        }else{
            [self.contentTableView footerEndRefreshing];
        }
    }];
}

// 处理获取评论列表
- (void)handleCommentData:(NSMutableArray *)data {
    [_contentArr addObjectsFromArray:data];
    [self.contentTableView reloadData];
}

// 申请添加评论
- (void)requestAddComment:(NSString *)comment {
    NSString *userId = [[_userIfo objectForKey:@"info"] objectForKey:@"uid"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId,
                                 @"ac_id":self.activityID,
                                 @"content":comment};
    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, ADD_COMMENT] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleAddComment];
            [AppUtils showLoadInfo:@"评论成功"];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleAddComment {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *uid = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *name = [app.store getStringById:USER_NICKNAME fromTable:USER_TABLE];
    NSString *avatar = [app.store getStringById:USER_HEAD_PIC fromTable:USER_TABLE];
    [dic setValue:uid forKey:@"uid"];
    [dic setValue:name forKey:@"nikename"];
    [dic setValue:avatar forKey:@"avatar"];
    [dic setValue:_newCommentStr forKey:@"content"];
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *locationString = [dateformatter stringFromDate:nowDate];
    [dic setValue:locationString forKey:@"created_at"];
    [_contentArr insertObject:dic atIndex:0];
    [self.contentTableView reloadData];
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
