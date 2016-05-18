//
//  CenterMoreViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "CenterMoreViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"

#import "CommonWebViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UMFeedback.h"
#import "MobClick.h"

@interface CenterMoreViewController ()
{
    NSArray *_contentArr;
    float _viewWidth;
}

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

static NSString *cellIdentifiler = @"Cell";

@implementation CenterMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initData];
    // 内容列表
    self.contentTableview.delegate = self;
    self.contentTableview.dataSource = self;
    self.contentTableview.scrollEnabled = NO;
    self.contentTableview.tableFooterView =  [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    if ([self.contentTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.contentTableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.contentTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.contentTableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData {
    _contentArr = @[@"意见反馈",@"关于",@"灰色分隔",@"版本信息",@"给予好评"];
    _viewWidth = self.view.bounds.size.width;
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        self.logoutBtn.hidden= NO;
    }else{
        self.logoutBtn.hidden= YES;
    }
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        // 做灰色20个像素间隔用， cell的header或是footer 没有下横线不好看
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }else{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
        
        if (_contentArr.count <= indexPath.row) {
            return cell;
        }
        
        cell.textLabel.font = GENERAL_FONT15;
        cell.textLabel.text = _contentArr[indexPath.row];
        
        UILabel *infolabel = (UILabel *)[cell viewWithTag:10];
        if (infolabel == nil) {
            infolabel = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 230, 0, 200, 44)];
            infolabel.font = GENERAL_FONT15;
            infolabel.tag = 10;
            infolabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:infolabel];
        }
        
        infolabel.hidden = YES;
        infolabel.text = [NSString stringWithFormat:@"当前版本V%@", [AppUtils appVersion]];
        
        if ([_contentArr[indexPath.row] isEqual:@"版本信息"]) {
            infolabel.hidden = NO;
        }
        
        return cell;
    }
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 10;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 2){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = GENERAL_COLOR_GRAY2;
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
        [self presentViewController:[UMFeedback feedbackModalViewController] animated:YES completion:nil];
    }else if (indexPath.row == 1){
        CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
        vc.url = URL_ABOUT;
        vc.titleString= @"关于";
        [AppUtils pushPage:self targetVC:vc];
    }else if (indexPath.row == 4){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=952703395&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
    }else{
        return;
    }
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (IBAction)logOut:(UIButton *)sender {
    UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，确定要退出登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [msgbox show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString* btn = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btn isEqualToString:@"确定"]) {
        [self userLogout];
    }
}

#pragma mark 数据处理
// 退出账号登录请求
- (void)userLogout{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.store clearTable:USER_TABLE];
    [AppUtils showLoadInfo:@"账号注销成功"];
    
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:userId forKey:@"uid"];
        [parameters setValue:token forKey:@"token"];
        NSString *signStr = [AppUtils makeSignStr:parameters];
        [parameters setValue:signStr forKey:@"sign"];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, USER_LOG_OUT] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary* jsonData = [operation.responseString objectFromJSONString];
            if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];
    [self back:nil];
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
