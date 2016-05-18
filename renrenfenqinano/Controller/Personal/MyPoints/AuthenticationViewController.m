//
//  AuthenticationViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "AuthenticationPictureViewController.h"

#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

#import "ProvincesSelectionViewController.h"

@interface AuthenticationViewController ()
{
    NSMutableArray *_schoolArr;
    NSMutableArray *_infoArr; // 缓存所属地数据
}

@property (strong, nonatomic) NSString *provinceString;// 所属地
@property (strong, nonatomic) NSString *schoolString;// 学校
@property (strong, nonatomic) NSString *schoolId;// 学校ID

@end

static NSString *cellIdentifiler = @"Cell";

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSchoolInfo:) name:GET_SCHOLL_LIST object:nil];
    
    [self initData];
    
    self.nameTextFiled.delegate = self;
    self.nameTextFiled.returnKeyType = UIReturnKeyNext;
    self.identityCardTextFiled.delegate = self;
    self.identityCardTextFiled.returnKeyType = UIReturnKeyNext;
    self.studentIDTextFiled.delegate = self;
    self.studentIDTextFiled.returnKeyType = UIReturnKeyDone;
    
    self.schoolTableview.delegate = self;
    self.schoolTableview.dataSource= self;
    self.schoolTableview.scrollEnabled = NO;
    
    [self.schoolTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.schoolTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.schoolTableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.schoolTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.schoolTableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    // 获取当前玩家的认证信息
    [self getStudentAuthIfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initData
{
    self.provinceString = @"";
    self.schoolString = @"";
    _schoolArr = [NSMutableArray array];
    _infoArr = [NSMutableArray array];
}

#pragma mark 数据处理

- (void)getStudentAuthIfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid":userId};
    
    [AppUtils showLoadIng:@"数据加载中"];
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, STUDENT_AUTH] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleStudentAuthIfo:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)postStudentAuthIfo:(NSString *)userId name:(NSString *)nameStr identity:(NSString *)identityStr studentId:(NSString *)stuIdStr schoolId:(NSString *)schoolIdStr
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId,
                                 @"name":nameStr,
                                 @"school_id":schoolIdStr,
                                 @"student_id":stuIdStr,
                                 @"identity":identityStr};
    
    [AppUtils showLoadIng:@"认证信息提交中"];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, STUDENT_AUTH] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            AuthenticationPictureViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthenticationPictureIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleStudentAuthIfo:(NSDictionary *)dic
{
    if (dic.count > 0) {
        if ([[dic allKeys] containsObject:@"name"]) {
            self.nameTextFiled.text = [AppUtils filterNull:[dic objectForKey:@"name"]];
        }
        
        if ([[dic allKeys] containsObject:@"identity"]) {
            self.identityCardTextFiled.text = [AppUtils filterNull:[dic objectForKey:@"identity"]];
        }
        
        if ([[dic allKeys] containsObject:@"student_id"]) {
            self.studentIDTextFiled.text = [AppUtils filterNull:[dic objectForKey:@"student_id"]];;
        }
        
        if ([[dic allKeys] containsObject:@"school_name"]) {
            self.schoolString = [AppUtils filterNull:[dic objectForKey:@"school_name"]];
        }
        
        if ([[dic allKeys] containsObject:@"school_id"]) {
            self.schoolId = [AppUtils filterNull:[dic objectForKey:@"school_id"]];
        }
        
        [self.schoolTableview reloadData];
    }
}

- (void)getProvincesFromAPI:(NSString *)parentId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"parent_id": parentId};
    
    [AppUtils showLoadIng:@""];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, GET_PROVINECES] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleProvincesData:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleProvincesData:(NSDictionary *)data
{
    ProvincesSelectionViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"ProvincesSelectionIdentifier"];
    vc.dataArr = [[data objectForKey:@"data"] mutableCopy];
    vc.locationArr = [NSMutableArray array];
    [AppUtils pushPage:self targetVC:vc];
}

- (void)handleSchoolInfo:(NSNotification*)notifiction
{
    _infoArr = [notifiction.userInfo valueForKey:LOCTION_KEY];
    
    if (_infoArr.count == 1) {
        self.schoolString = @"";
        self.provinceString = [[_infoArr objectAtIndex:0] objectForKey:@"region_name"];
        [self.schoolTableview reloadData];
    }else if (_infoArr.count == 2){
        self.schoolString = @"";
        self.provinceString = [NSString stringWithFormat:@"%@%@",[[_infoArr objectAtIndex:0] objectForKey:@"region_name"],[[_infoArr objectAtIndex:1] objectForKey:@"region_name"]];
        [self.schoolTableview reloadData];
    }else if (_infoArr.count == 3){
        self.schoolString = @"";
        self.provinceString = [NSString stringWithFormat:@"%@%@%@",[[_infoArr objectAtIndex:0] objectForKey:@"region_name"],[[_infoArr objectAtIndex:1] objectForKey:@"region_name"],[[_infoArr objectAtIndex:2] objectForKey:@"region_name"]];
        [self.schoolTableview reloadData];
    }else{
        return;
    }
}

- (void)getSchoolListFromAPI:(NSString*)provinceId city:(NSString *)cityId district:(NSString *)districtId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"province_id": provinceId,
                                 @"city_id": cityId,
                                 @"district_id": districtId};
    
    [AppUtils showLoadIng:@""];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, GET_SCHOOL_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleSchoolList:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleSchoolList:(NSDictionary*) data {
    _schoolArr = [[data objectForKey:@"data"] mutableCopy];
    if (_schoolArr.count ==0) {
        [AppUtils showLoadInfo:@"请先选择学校所属地"];
    }else{
        NSLog(@"加载学校列表");
        SchoolListViewController * vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"SchoolIdentifier"];
        vc.delegate = self;
        vc.schoolArr = _schoolArr;
        [AppUtils pushPage:self targetVC:vc];
    };
    
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    
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
    
    if (indexPath.row == 0) {
        contentLabel.text = [NSString stringWithFormat:@"学校所属地： %@", self.provinceString];
    }else if (indexPath.row == 1){
        contentLabel.text = [NSString stringWithFormat:@"就读学校： %@", self.schoolString];
    }else{
        contentLabel.text = @"";
    }
    
    return cell;
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSLog(@"选择学校所属地");
        [self getProvincesFromAPI:@""];
    }else if (indexPath.row == 1){
        if (_infoArr.count == 1) {
            [self getSchoolListFromAPI:[[_infoArr objectAtIndex:0] objectForKey:@"region_id"] city:@"" district:@""];
        }else if (_infoArr.count == 2){
            [self getSchoolListFromAPI:[[_infoArr objectAtIndex:0] objectForKey:@"region_id"] city:[[_infoArr objectAtIndex:1] objectForKey:@"region_id"] district:@""];
        }else if (_infoArr.count == 3){
            [self getSchoolListFromAPI:[[_infoArr objectAtIndex:0] objectForKey:@"region_id"] city:[[_infoArr objectAtIndex:1] objectForKey:@"region_id"] district:[[_infoArr objectAtIndex:2] objectForKey:@"region_id"]];
        }else {
            [AppUtils showLoadInfo:@"请先选择学校所属地"];
        }
    }
}

#pragma mark - 按钮响应

- (IBAction)next:(UIButton *)sender
{
    /*
     NSDictionary *parameters = @{@"uid":userId,
     @"name":self.nameTextFiled.text,
     @"school_id":self.schoolId,
     @"student_id":self.studentIDTextFiled.text,
     @"identity":self.identityCardTextFiled.text};
     */
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils judgeStrIsEmpty:self.nameTextFiled.text]) {
        [AppUtils showLoadInfo:@"姓名不能为空"];
    }else if ([AppUtils judgeStrIsEmpty:self.identityCardTextFiled.text]){
        [AppUtils showLoadInfo:@"身份证号码不能为空"];
    }else if ([AppUtils judgeStrIsEmpty:self.studentIDTextFiled.text]){
        [AppUtils showLoadInfo:@"学号不能为空"];
    }else if ([AppUtils judgeStrIsEmpty:self.schoolId]){
        [AppUtils showLoadInfo:@"就读学校不能为空"];
    }else{
        [self postStudentAuthIfo:userId name:self.nameTextFiled.text identity:self.identityCardTextFiled.text studentId:self.studentIDTextFiled.text schoolId:self.schoolId];
    }
}

- (IBAction)back:(UIButton *)sender
{
    [AppUtils goBack:self];
}

- (void)selectSchool:(NSDictionary *)schoolDic
{
    self.schoolString = [schoolDic objectForKey:@"school_name"];
    self.schoolId =  [schoolDic objectForKey:@"school_id"];
    [self.schoolTableview reloadData];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextFiled]) {
        [self.nameTextFiled resignFirstResponder];
        [self.identityCardTextFiled becomeFirstResponder];
    }else if ([textField isEqual:self.identityCardTextFiled]){
        [self.identityCardTextFiled resignFirstResponder];
        [self.studentIDTextFiled becomeFirstResponder];
    }else if ([textField isEqual:self.studentIDTextFiled]){
        [self.studentIDTextFiled resignFirstResponder];
    }
    
    return YES;
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
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
