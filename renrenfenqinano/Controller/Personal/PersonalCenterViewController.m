//
//  PersonalCenterViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "AppDelegate.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#import "CenterMoreViewController.h"
#import "RedPacketViewController.h"
#import "MyPointsViewController.h"
#import "CommonWebViewController.h"
#import "PersonalInfoViewController.h"
#import "ChangePassWordViewController.h"

#import "UserLoginViewController.h"
#import "MyOrdersViewController.h"
#import "MyBillsViewController.h"
#import "CreditAccountViewController.h"
#import "UIButton+WebCache.h"

#import "WishViewController.h"
#import "JobSettingViewController.h"
#import "MyJobsViewController2.h"
#import "PersonalTableViewCell.h"

#import "RFAutheticationSelectViewController.h"
#import "RFAuthManager.h"

@interface PersonalCenterViewController ()<PersonalTableViewCellProtocol>
{
    NSArray *_contentArr;
    NSArray *_menuTitleArr;
    UIStoryboard   *_mainStoryboard;
    NSMutableArray *_buttonArr;
    
    float _defaultHeadViewHeight;
}

@end

static NSString *cellIdentifiler = @"Cell";

@implementation PersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initData];
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePersonalInfo) name:UPDATE_PERSONNAL_INFO object:nil];
    
    self.excircleView.layer.cornerRadius = 39.0f;
    self.excircleView.layer.masksToBounds = YES;
    [self.excircleView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
    self.headPicBtn.layer.cornerRadius = 35.0f;
    self.headPicBtn.layer.masksToBounds = YES;
    
    [self.grayBackground setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.1]];
    
    CGRect rect = self.headView.frame;
    rect.size.width = self.view.frame.size.width;
    rect.size.height = _defaultHeadViewHeight;//ceilf(self.view.frame.size.width /320 * 165);
    self.headView.frame = rect;
    
    // 添加头部view的拉伸动画
    self.stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    [self.stretchableTableHeaderView stretchHeaderForTableView:self.contentTableView withView:self.headView];
    
    [self updatePersonalInfo];
    
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    [self.contentTableView registerClass:[PersonalTableViewCell class] forCellReuseIdentifier:@"PersonTableViewCell"];
    self.contentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.contentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.contentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.contentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.contentTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self createMenu];
}

- (void)createMenu {
    CGRect bounds = self.view.bounds;
    float buttonWidth = bounds.size.width/3;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, 7.5f, 0.5, 30)];
    line1.backgroundColor = UIColorFromRGB(0xddd4a1);
    [self.grayBackground addSubview:line1];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(2*buttonWidth + 1, 7.5f, 0.5, 30)];
    line2.backgroundColor = UIColorFromRGB(0xddd4a1);
    [self.grayBackground addSubview:line2];
    
    UIButton *button = nil;
    for (int index = 0; index < 3; index++) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(index*buttonWidth, 0, buttonWidth, 45);
        [button setTitle:[_menuTitleArr objectAtIndex:index] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        button.tag = index + 1;
        [button addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.grayBackground addSubview:button];
        
        [_buttonArr addObject:button];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        [self getUserCenterInfo:userId];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 数据处理

- (void)initData {
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    _buttonArr = [NSMutableArray array];
    _menuTitleArr = @[@"0\n我的红包", @"0\n消费额度", @"0\n我的积分"];
    _contentArr = @[@"心愿单",@"我的订单",@"信用账户",@"我的兼职",@"兼职简历",@" ",@"修改密码",@"客服热线",@"使用帮助"];
    
    _defaultHeadViewHeight = 165.0f;
}

// 更新个人中心用户信息
- (void)updatePersonalInfo {
    NSString *headImgHeadPath = @"";
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        self.nickNameLabel.text = [app.store getStringById:USER_NICKNAME fromTable:USER_TABLE];
        headImgHeadPath = [app.store getStringById:USER_HEAD_PIC fromTable:USER_TABLE];
        self.grayBackground.hidden = NO;
        self.signBtn.hidden = YES;
    }else{
        // 没有登录
        self.nickNameLabel.text = @"欢迎来到仁仁分期";
        self.grayBackground.hidden = YES;
        self.signBtn.hidden = NO;
    }
    
    [self.headPicBtn sd_setImageWithURL:[NSURL URLWithString:headImgHeadPath]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"my_body_headportrait_n@2x.png"]];
}

// 获取用户中心消费额度，积分，红包
- (void)getUserCenterInfo:(NSString *)userId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"uid":[NSString stringWithFormat:@"%@", userId]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, GET_USER_CENTER_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleUserCenterInfo:[jsonData objectForKey:@"data"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)handleUserCenterInfo:(NSDictionary *)dic{
    NSString *all = [AppUtils filterNull:[dic objectForKey:@"all"]];
    NSString *credit = [AppUtils filterNull:[dic objectForKey:@"credit"]];
    NSString *intergral = [AppUtils filterNull:[dic objectForKey:@"intergral"]];
    NSString *redMoney = [AppUtils filterNull:[dic objectForKey:@"red_money"]];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.store putString:[AppUtils filterNull:all] withId:USER_CREDIT_ALL intoTable:USER_TABLE];
    
    // button.tag 要和 [self createMenu]中创建保持一致
    for (UIButton *button in _buttonArr) {
        if (button.tag == 1) {
            [button setTitle:[NSString stringWithFormat:@"%@\n我的红包", redMoney] forState:UIControlStateNormal];
        }else if (button.tag == 2){
           [button setTitle:[NSString stringWithFormat:@"%@\n消费额度", credit] forState:UIControlStateNormal];
        }else if (button.tag == 3){
            [button setTitle:[NSString stringWithFormat:@"%@\n我的积分", intergral] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return _contentArr.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }else if(indexPath.row == 0){
        PersonalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonTableViewCell"];
        cell.delegate = self;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
        
        if (_contentArr.count <= indexPath.row-1) {
            return cell;
        }
        
        UIImageView *iconImage = (UIImageView *)[cell viewWithTag:10];
        if (iconImage == nil) {
            iconImage = [[UIImageView alloc] init];
            iconImage.frame = CGRectMake(15.0f, 0.5*(44.0f - 22.0f), 22.0f, 22.0f);
            iconImage.alpha = 1;
            iconImage.tag = 10;
            [cell addSubview:iconImage];
        }
        
        UILabel *iconlabel = (UILabel *)[cell viewWithTag:11];
        if (iconlabel == nil) {
            iconlabel = [[UILabel alloc] init];
            iconlabel.font = GENERAL_FONT15;
            iconlabel.textColor = UIColorFromRGB(0x666666);
            iconlabel.alpha = 1;
            iconlabel.tag = 11;
            [cell addSubview:iconlabel];
        }
        
        iconlabel.text = _contentArr[indexPath.row-1];
        CGSize textsize = [iconlabel.text sizeWithAttributes:@{NSFontAttributeName:iconlabel.font}];
        iconlabel.frame = CGRectMake(iconImage.frame.origin.x + iconImage.frame.size.width + 15.0f, 0.5*(44.0f - textsize.height) - 1.0f, textsize.width, textsize.height);
        iconImage.image = [self iconImageFromIconName:iconlabel.text];
        
//        cell.textLabel.font = GENERAL_FONT15;
//        cell.textLabel.textColor = UIColorFromRGB(0x666666);
//        cell.textLabel.text = _contentArr[indexPath.row];
//        cell.imageView.image = [self iconImageFromIconName:cell.textLabel.text];
        
        return cell;
    }
}

- (UIImage *)iconImageFromIconName:(NSString *)iconName {
    NSString *tempName = @"";
    if ([iconName isEqualToString:@"心愿单"]) {
        tempName = @"personalcenter_body_wishlist_n@2x.png";
    }else if ([iconName isEqualToString:@"我的订单"]) {
        tempName = @"personalcenter_body_order_n@2x.png";
    }else if ([iconName isEqualToString:@"信用账户"]) {
        tempName = @"personalcenter_body_bill_n@2x.png";
    }else if ([iconName isEqualToString:@"我的兼职"]) {
        tempName = @"personalcenter_body_parttime_n@2x.png";
    }else if ([iconName isEqualToString:@"兼职简历"]) {
        tempName = @"personalcenter_body_resume_n@2x.png";
    }else if ([iconName isEqualToString:@"修改密码"]) {
        tempName = @"personalcenter_body_password_n@2x.png";
    }else if ([iconName isEqualToString:@"客服热线"]) {
        tempName = @"personalcenter_body_customerservice_n@2x.png";
    }else if ([iconName isEqualToString:@"使用帮助"]) {
        tempName = @"personalcenter_body_help_n@2x.png";
    }
    
    return [UIImage imageNamed:tempName];
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return ceil([UIScreen mainScreen].bounds.size.width / 3) * 140.0f / 213.0f;
    }
    if (indexPath.row == 6){
        return 10.0f; // 灰色分割高度
    }
    
    return 44.5f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row == 5){
        cell.backgroundColor = GENERAL_COLOR_GRAY2;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
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
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if (indexPath.row == 1){
        WishViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WishIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
        
    }else if (indexPath.row == 2){
        if ([AppUtils isLogined:userId]) {
            MyOrdersViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"MyOrdersIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:@"请登录账号"];
        }
    }else if (indexPath.row == 3){
        if ([AppUtils isLogined:userId]) {
            CreditAccountViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"CreditAccountIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:@"请登录账号"];
        }
    }else if (indexPath.row == 4){
        if ([AppUtils isLogined:userId]) {
            MyJobsViewController2 *vc = [[MyJobsViewController2 alloc] init];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:@"请登录账号"];
        }
        
    }else if (indexPath.row == 5){
        if ([AppUtils isLogined:userId]) {
            JobSettingViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"JobSettingIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:@"请登录账号"];
        }
        
    }else if (indexPath.row == 6){
        return;
    }else if (indexPath.row == 7){
        if ([AppUtils isLogined:userId]) {
            ChangePassWordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:@"请先登录账号"];
        }
        
    }else if (indexPath.row == 8) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://4007800087"]];
    }else if (indexPath.row == 9) {
        CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
        vc.url = URL_HELP;
        vc.titleString = @"帮助中心";
        [AppUtils pushPage:self targetVC:vc];
    }
}

#pragma  mark 按钮响应

- (IBAction)lookMore:(UIButton *)sender {
    CenterMoreViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CenterMoreIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)touchHeadBtn:(UIButton *)sender {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        PersonalInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalInfoIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }else{
        [AppUtils showLoadInfo:@"请先登录账号"];
    }
}

- (IBAction)touchSignInBtn:(UIButton *)sender {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        return;
    }else{
        UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        vc.writeInfoMode = WriteInfoModeOption;
        vc.parentClass = [PersonalCenterViewController class];
        [AppUtils pushPageFromBottomToTop:self targetVC:vc];
    }
}

// 登录状态才能显示积分 消费额度 红包按钮
- (void)menuButton:(UIButton *)button {
    if (button.tag == 1) {
        RedPacketViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RedPacketIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }else if (button.tag == 2) {
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSString *allValue = [AppUtils filterNull:[app.store getStringById:USER_CREDIT_ALL fromTable:USER_TABLE]];
        NSString *message = [NSString stringWithFormat:@"您在仁仁分期的消费额度上限为%@元，购买商品后消费额度会相应减少，还款成功后消费额度会相应恢复。", allValue];
        [AppUtils showAlertViewWithTitle:@"消费额度" message:message];
    }else if (button.tag == 3) {
        MyPointsViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"MyPointsIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }
}

#pragma mark 处理下拉图片放大效果

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.stretchableTableHeaderView scrollViewDidScroll:scrollView];
}

- (void)viewDidLayoutSubviews
{
    [self.stretchableTableHeaderView resizeView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma -mark HomepageFunctionTableViewCell
-(void)clickLeftButton
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    NSString *token = [loginInfo objectForKey:@"token"];
    if ([AppUtils isLogined:uid]) {
        [[RFAuthManager defaultManager] getStudentAutheticationInfomationWithUid:uid WithToken:token Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *resultDic = (NSDictionary *)responseObject;
            if (resultDic) {
                NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                Student *student = [[Student alloc] initWithDictionary:dataDic];
                if (student) {
                    RFAutheticationSelectViewController *rfAutheticationSelectVC = [[RFAutheticationSelectViewController alloc] initWithStudent:student];
                    [AppUtils pushPage:self targetVC:rfAutheticationSelectVC];
                }
            }
            
        } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
            [AppUtils showInfo:[responseObject objectForKey:@"message"]];
        } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppUtils showInfo:@"网络错误"];
        }];

    }
}

-(void)clickMiddleButton
{
    
}

-(void)clickRightButton
{
    
}
@end
