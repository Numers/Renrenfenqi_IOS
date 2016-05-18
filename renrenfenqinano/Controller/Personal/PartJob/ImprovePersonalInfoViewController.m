//
//  ImprovePersonalInfoViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ImprovePersonalInfoViewController.h"
#import "ImprovePersonalInfoViewController2.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "ProvincesSelectionViewController.h"

@interface ImprovePersonalInfoViewController ()
{
    NSMutableDictionary *_myjobSetting;
    NSMutableArray      *_schoolArr;
    NSMutableArray      *_infoArr; // 缓存所属地数据
    NSDictionary        *_selectSchoolDic;
    NSString            *_sexValue;
}

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *personalView;


@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *qqTextField;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) DateSelectionView* dateView;

@end

@implementation ImprovePersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSchoolInfo:) name:GET_SCHOLL_LIST object:nil];
    // 初始化本页数据
    [self initData];
    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    if ([AppUtils isLogined:userId]) {
        [self requestParttimeInfo:userId];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resignAllFirstResponder{
    [self.view endEditing:YES];
    if (self.dateView != nil) {
        [self.dateView dismiss];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initData {
    _myjobSetting = [NSMutableDictionary dictionary];
    _schoolArr = [NSMutableArray array];
    _infoArr = [NSMutableArray array];
    self.nextBtn.enabled = YES;
    
    self.areaLabel.text = @"";
    self.schoolLabel.text = @"";
    self.birthdayLabel.text = @"";
    _sexValue = @"M";
    
    self.nameTextField.delegate = self;
    self.nameTextField.returnKeyType = UIReturnKeyNext;
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    
    self.phoneTextField.delegate = self;
    self.phoneTextField.returnKeyType = UIReturnKeyNext;
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.qqTextField.delegate = self;
    self.qqTextField.returnKeyType = UIReturnKeyDone;
    self.qqTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if (self.isSkip) {
        self.skipBtn.hidden = NO;
    }else{
        self.skipBtn.hidden = YES;
    }
}



- (void)handleSchoolInfo:(NSNotification*)notifiction {
     _infoArr = [notifiction.userInfo valueForKey:LOCTION_KEY];
    
    if (_infoArr.count == 1) {
        self.schoolLabel.text = @"";
        self.areaLabel.text = [[_infoArr objectAtIndex:0] objectForKey:@"region_name"];
    }else if (_infoArr.count == 2){
        self.schoolLabel.text = @"";
        self.areaLabel.text = [NSString stringWithFormat:@"%@%@",[[_infoArr objectAtIndex:0] objectForKey:@"region_name"],[[_infoArr objectAtIndex:1] objectForKey:@"region_name"]];
    }else if (_infoArr.count == 3){
        self.schoolLabel.text = @"";
        self.areaLabel.text = [NSString stringWithFormat:@"%@%@%@",[[_infoArr objectAtIndex:0] objectForKey:@"region_name"],[[_infoArr objectAtIndex:1] objectForKey:@"region_name"],[[_infoArr objectAtIndex:2] objectForKey:@"region_name"]];
    }else{
        return;
    }
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.dateView dismiss];
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
    }else if (textField == self.phoneTextField) {
        [self.phoneTextField resignFirstResponder];
    }else if (textField == self.qqTextField) {
        [self.qqTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark 获取是否完善资料和求职意向
- (void)requestParttimeInfo:(NSString *)userId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"uid":userId};
    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            _myjobSetting = [jsonData objectForKey:@"data"];
            if ([[_myjobSetting objectForKey:@"is_info"]intValue] == 1) {
                [self handleParttimeInfo];
            }
        }
        else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleParttimeInfo {
    self.nameTextField.text = [AppUtils readAPIField:_myjobSetting key:@"name"];
    self.schoolLabel.text = [AppUtils readAPIField:_myjobSetting key:@"school_name"];
    self.phoneTextField.text = [AppUtils readAPIField:_myjobSetting key:@"phone"];
    self.birthdayLabel.text = [AppUtils readAPIField:_myjobSetting key:@"birthday"];
    self.qqTextField.text = [AppUtils readAPIField:_myjobSetting key:@"qq"];
    
    NSString* sexStr = [AppUtils readAPIField:_myjobSetting key:@"sex"];
    if ([sexStr isEqual:@"男"]) {
        self.sexSelectBtn.selectedSegmentIndex = 0;
    }else{
        self.sexSelectBtn.selectedSegmentIndex = 1;
    }
    
    NSMutableArray* areaArr = [NSMutableArray arrayWithArray:[_myjobSetting objectForKey:@"schoolData"]];
    NSString *areaStr = @"";
    for (int index = 0; index < areaArr.count; index ++) {
        areaStr = [areaStr stringByAppendingString:[[areaArr objectAtIndex:index] objectForKey:@"name"]];
    }
    
    self.areaLabel.text = areaStr;
    
    _selectSchoolDic = @{@"school_id":[AppUtils readAPIField:_myjobSetting key:@"school_id"], @"school_name":[AppUtils readAPIField:_myjobSetting key:@"school_name"]};
}

- (void)getProvincesFromAPI:(NSString *)parentId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"parent_id": parentId};
    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, GET_PROVINECES] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            [self handleProvincesData:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleProvincesData:(NSDictionary *)data {
    ProvincesSelectionViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"ProvincesSelectionIdentifier"];
    vc.dataArr = [[data objectForKey:@"data"] mutableCopy];
    vc.locationArr = [NSMutableArray array];
    [AppUtils pushPage:self targetVC:vc];
}

- (void)getSchoolListFromAPI:(NSString*)provinceId city:(NSString *)cityId district:(NSString *)districtId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"province_id": provinceId,
                                 @"city_id": cityId,
                                 @"district_id": districtId};
    
    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, GET_SCHOOL_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
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

- (void)postJobInfo:(NSString *)name schoolID:(NSString *)schoolid phoneNum:(NSString *)num bithday:(NSString *)date sex:(NSString *)sexValue wx:(NSString *)wxNum{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    if ([AppUtils isNullStr:wxNum]) {
        wxNum = @"";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"uid":userId,
                                 @"name":name,
                                 @"school_id":schoolid,
                                 @"birthday":date,
                                 @"phone":num,
                                 @"sex":sexValue,
                                 @"qq":wxNum};
    
    [AppUtils showLoadIng];
    self.nextBtn.enabled = NO;
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, POST_JOB_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.nextBtn.enabled = YES;
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@"个人资料完善成功"];
            [self handlePostJobInfoSuccess];
        }
        else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.nextBtn.enabled = YES;
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handlePostJobInfoSuccess {
    if (self.isSkip) {
        [self skip:nil];
    }else{
        ImprovePersonalInfoViewController2 *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
        vc.theViewClass = self.theViewClass;
        
        if ([[_myjobSetting allKeys] containsObject:@"job_time"]) {
            if ([[_myjobSetting objectForKey:@"job_time"] isKindOfClass:[NSArray class]]) {
                vc.myDayArr = [[_myjobSetting objectForKey:@"job_time"] mutableCopy];
            }
            else
            {
                vc.myDayArr = [NSMutableArray array];
            }
        }
        if ([[_myjobSetting allKeys] containsObject:@"intent"]) {
            if ([[_myjobSetting objectForKey:@"intent"] isKindOfClass:[NSArray class]]) {
                vc.myJobsArr = [[_myjobSetting objectForKey:@"intent"] mutableCopy];
            }else {
                vc.myJobsArr = [NSMutableArray array];
            }
        }
        
        [AppUtils pushPage:self targetVC:vc];
    }
}

#pragma mark  学校选择代理
- (void)selectSchool:(NSDictionary *)schoolDic {

    self.schoolLabel.text = [schoolDic objectForKey:@"school_name"];
    _selectSchoolDic = schoolDic;
}


#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (IBAction)skip:(UIButton *)sender {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[self.theViewClass class]]) {
            [AppUtils popToPage:self targetVC:controller];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_JOBSETTING_OK object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_ONLY_PARTTIME_DATA object:nil];
}

- (IBAction)nextBtn:(UIButton *)sender {
    
    if ([self judgeInfo]) {
        
        [self postJobInfo:self.nameTextField.text schoolID:[_selectSchoolDic objectForKey:@"school_id"] phoneNum:self.phoneTextField.text bithday:self.birthdayLabel.text sex:_sexValue wx:self.qqTextField.text];
    }
}

- (BOOL)judgeInfo {
    if ([AppUtils isNullStr:self.nameTextField.text]) {
        [AppUtils showLoadInfo:@"姓名不能为空"];
        return NO;
    }else if ([AppUtils isNullStr:[_selectSchoolDic objectForKey:@"school_id"]]) {
        [AppUtils showLoadInfo:@"请选择学校"];
        return NO;
    }else if (![AppUtils isMobileNumber:self.phoneTextField.text]) {
        [AppUtils showLoadInfo:@"无效电话号码，请重新填写"];
        return NO;
    }else if ([AppUtils isNullStr:self.birthdayLabel.text]) {
        [AppUtils showLoadInfo:@"请选择生日日期"];
        return NO;
    }else if ([AppUtils isNullStr:self.qqTextField.text]) {
        [AppUtils showLoadInfo:@"请输入QQ号码"];
        return NO;
    }
    
    return YES;
}

- (IBAction)areaSelectBtn:(UIButton *)sender {
    [self getProvincesFromAPI:@""];
}

- (IBAction)schoolBtn:(UIButton *)sender {
    
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

- (IBAction)birthdayBtn:(UIButton *)sender {
    
    self.dateView = [[DateSelectionView alloc] initDateView];
    self.dateView.delegate = self;
    
    [self.dateView show];
}


- (IBAction)sexSelectBtn:(UISegmentedControl *)sender {
     NSInteger index = sender.selectedSegmentIndex;
    if (index == 0) {
        _sexValue = @"M";
    }else{
        _sexValue = @"F";
    }
}

#pragma mark DateSelectionViewDelegate 
- (void)saveDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    self.birthdayLabel.text = strDate;
                               
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
