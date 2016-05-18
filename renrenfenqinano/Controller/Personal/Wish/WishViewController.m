//
//  WishViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "WishViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

#import "MyWishViewController.h"
#import "WishCommitViewController.h"
#import "UserLoginViewController.h"

@interface WishViewController ()
{
    NSMutableArray *_hotwishArr;
    UIStoryboard *_mainStoryboard;
}

@property (weak, nonatomic) IBOutlet UITableView *wishTableView;


@end

static NSString *cellIdentifiler = @"hotWishIdentifier";     // 热门心愿单
static NSString *wishCellIdentifiler = @"wishIdentifier";    // 心愿单首页顶部信息列表
static NSString *tipsCellIdentifiler = @"hotTipsIdentifier"; // 热门心愿单提示语

@implementation WishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    self.wishTableView.dataSource = self;
    self.wishTableView.delegate = self;
    self.wishTableView.bounces = NO;
    
    if ([self.wishTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.wishTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.wishTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.wishTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWishList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 数据处理
- (void)initData
{
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _hotwishArr = [NSMutableArray array];
    [_hotwishArr addObject:@""];
}

// 获取热门心愿单列表
- (void)getWishList
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if (![AppUtils isLogined:userId]) {
        userId = @"";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[NSString stringWithFormat:@"%@", userId]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, GET_WISH_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _hotwishArr = [[jsonData objectForKey:@"data"] mutableCopy];
            [self.wishTableView reloadData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

// 提交心愿单
- (void)commitMyWish:(NSString *)phoneNum goods:(NSString *)goodsName userId:(NSString *)uid
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":uid,
                                 @"client_type":@"2",
                                 @"phone":[NSString stringWithFormat:@"%@", phoneNum],
                                 @"goods_name":[NSString stringWithFormat:@"%@", goodsName]};
    
    [AppUtils showLoadIng:@"心愿单提交中"];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, COMMIT_MY_WISH] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            WishCommitViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WishCommitIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
            
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

// 提交心愿单点赞
- (void)commitHotWishPraise:(int)wishId userId:(NSString *)uid
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"uid":uid,
                                 @"wish_id":[NSString stringWithFormat:@"%d", wishId]};
    
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, COMMIT_WISH_PRAISE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
//            [self AddWishPraiseCount:wishId count:[[jsonData objectForKey:@"laud"] intValue]];
            // 修改，点赞后重新获取热门心愿单排名
            [self getWishList];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

//- (void)AddWishPraiseCount:(int)wishId count:(int)laudValue
//{
//    // 第一个数据本地设置,用于做标题提示，内容为：热门心愿单：。。。。。。。
//    if (_hotwishArr.count < 2) {
//        return;
//    }
//
//    for (int index = 1; index < _hotwishArr.count; index++) {
//        NSDictionary *dic = [_hotwishArr objectAtIndex:index];
//        if ([[dic objectForKey:@"wish_id"] intValue] == wishId) {
//            NSDictionary *temp = @{@"wish_id":[NSString stringWithFormat:@"%d",wishId],
//                                   @"goods_name":[dic objectForKey:@"goods_name"],
//                                   @"laud":[NSString stringWithFormat:@"%d",laudValue]};
//            
//            [_hotwishArr replaceObjectAtIndex:index withObject:temp];
//        }
//    }
//    
//    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
//    [self.wishTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
//    
//}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 160 + self.view.frame.size.width * 0.36;
        case 1:
            return 44;
        default:
            return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
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
            return 1;
        case 1:
            return _hotwishArr.count;
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
            WishTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:wishCellIdentifiler forIndexPath:indexPath];
            cell.delegate = self;
            
            return cell;
        }
        case 1:
        {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipsCellIdentifiler forIndexPath:indexPath];
                
                return cell;
            }else{
                SingleHotWishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
                
                if (_hotwishArr.count <= indexPath.row) {
                    return cell;
                }
                
                cell.delegate = self;
                cell.rankString = [NSString stringWithFormat:@"NO%d", (int)indexPath.row];
                [cell hotWishData:[_hotwishArr objectAtIndex:indexPath.row]];
                
                return cell;
            }
        }
        default:
        {
            return nil;
        }
    }
}

#pragma mark 心愿单主页顶部信息 wishTableViewCellDelegate

- (void)touchCommitBtn:(NSString *)phoneNum goods:(NSString *)goodsName userId:(NSString *)uid
{
    [self commitMyWish:phoneNum goods:goodsName userId:uid];
}

- (void)goLoginFromWish {
    
    [self LoginVc];
}

#pragma mark SingleHotWishTableViewCellDelegate 热门心愿单点赞

- (void)touchPraiseBtn:(int)hotWishId userId:(NSString *)uid
{
    [self commitHotWishPraise:hotWishId userId:uid];
}

- (void)goLoginFromHotWish {
    
    [self LoginVc];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

#pragma mark 按钮响应 

- (IBAction)back:(UIButton *)sender {
    
    [AppUtils goBack:self];
}

- (IBAction)myWish:(UIButton *)sender {
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        MyWishViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyWishIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }else{
        [self LoginVc];
    }
    
}

- (void)LoginVc {
    UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [WishViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
    
    [AppUtils showLoadInfo:@"请先登录账号"];
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
