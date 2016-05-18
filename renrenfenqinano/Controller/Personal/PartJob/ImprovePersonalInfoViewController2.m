//
//  ImprovePersonalInfoViewController2.m
//  renrenfenqi
//
//  Created by DY on 14/12/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ImprovePersonalInfoViewController2.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "CommonWebViewController.h"
#import "CommonVariable.h"

@interface ImprovePersonalInfoViewController2 ()
{
    NSMutableArray *_dayButtonsArr;
    NSMutableArray *_jobButtonsArr;
    
    NSMutableArray *_jobsArr;
    NSMutableArray *_daysArr;
    
    NSMutableArray *_dayIdArr;
    NSMutableArray *_jobIdArr;
    
    float _width;
    float _height;
    float _buttonWidth;
    float _buttonHeight;
}


@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (nonatomic, assign) BOOL isAgree;
@property (strong, nonatomic) UIButton *agreeBtn;
@property (strong, nonatomic) UIButton *okBtn;

@end

@implementation ImprovePersonalInfoViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    self.backgroundScrollView.backgroundColor = [UIColor whiteColor];
    
    [self getAllJobsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData {
    
    _dayIdArr = [NSMutableArray array];
    for (NSDictionary *dic in self.myDayArr) {
        NSString *tempId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        if (_dayIdArr.count == 0) {
            [_dayIdArr addObject:tempId];
        }else{
            BOOL isNew = YES;
            for (int index = 0; index < _dayIdArr.count; index ++) {
                if ([tempId isEqual:[_dayIdArr objectAtIndex:index]]) {
                    isNew = NO; break;
                }
            }
            if (isNew) {
                [_dayIdArr addObject:tempId];
            }
        }
    }
    _jobIdArr = [NSMutableArray array];
    for (NSDictionary *dic in self.myJobsArr) {
        NSString *tempId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        if (_jobIdArr.count == 0) {
            [_jobIdArr addObject:tempId];
        }else{
            BOOL isNew = YES;
            for (int index = 0; index < _jobIdArr.count; index ++) {
                if ([tempId isEqual:[_jobIdArr objectAtIndex:index]]) {
                    isNew = NO; break;
                }
            }
            if (isNew) {
                [_jobIdArr addObject:tempId];
            }
        }
    }
    
    _daysArr = [NSMutableArray arrayWithObjects:@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日", nil];
    _dayButtonsArr = [NSMutableArray array];
    
    _jobsArr = [NSMutableArray array];
    _jobButtonsArr = [NSMutableArray array];
    
    _width = self.view.bounds.size.width;
    _height = self.view.bounds.size.height;
    
    _buttonHeight = 25.0f;
    _buttonWidth = 65.0f;
    
    self.isAgree = YES;
    
}

- (void)initUI {
    
    UILabel *group1TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    group1TitleLabel.font = GENERAL_FONT14;
    group1TitleLabel.textAlignment = NSTextAlignmentLeft;
    group1TitleLabel.text = @"兼职时间：";
    [self.backgroundScrollView addSubview:group1TitleLabel];

    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 30, _width, 1)];
    line1.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.backgroundScrollView addSubview:line1];
    
    [self createWeakButtonsArr:15.0f startY:line1.frame.origin.y + line1.frame.size.height + 15];
    
    UIButton *temp = [_dayButtonsArr lastObject];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, temp.frame.origin.y + temp.frame.size.height + 15, _width, 1)];
    line2.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.backgroundScrollView addSubview:line2];
    
    UILabel *group2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, line2.frame.origin.y + line2.frame.size.height, 100, 30)];
    group2TitleLabel.font = GENERAL_FONT14;
    group2TitleLabel.textAlignment = NSTextAlignmentLeft;
    group2TitleLabel.text = @"求职意向：";
    [self.backgroundScrollView addSubview:group2TitleLabel];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, group2TitleLabel.frame.origin.y + group2TitleLabel.frame.size.height, _width, 1)];
    line3.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.backgroundScrollView addSubview:line3];
    
    [self  createJobButtonsArr:15.0f startY:line3.frame.origin.y + line3.frame.size.height + 15];
    
    temp = [_jobButtonsArr lastObject];
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, temp.frame.origin.y + temp.frame.size.height + 15, _width, 1)];
    line4.backgroundColor = UIColorFromRGB(0xe0e0e0);
    [self.backgroundScrollView addSubview:line4];
    
    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn.frame = CGRectMake(15.0f, line4.frame.origin.y + 70, self.view.frame.size.width - 30.0f, 44.0f);
    self.okBtn.layer.cornerRadius = 4.0f;
    self.okBtn.layer.masksToBounds = YES;
    self.okBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.okBtn addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
    [self updateOkbtn:YES];
    [self.backgroundScrollView addSubview:self.okBtn];
    
    self.agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.agreeBtn.frame = CGRectMake(self.okBtn.frame.origin.x + 5.0f, self.okBtn.frame.origin.y - 35, 23, 23);
    
    if (self.isAgree) {
        [self.agreeBtn setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_h"] forState:UIControlStateNormal];
    }else {
        [self.agreeBtn setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_n"] forState:UIControlStateNormal];
    }
    [self.agreeBtn addTarget:self action:@selector(agreeImageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:self.agreeBtn];
    
    CGSize size = [@"我已阅读并同意" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.agreeBtn.frame.origin.x  + self.agreeBtn.frame.size.width + 15, self.agreeBtn.frame.origin.y + 3, size.width, 13.0f)];
    agreeLabel.font = GENERAL_FONT13;
    agreeLabel.textAlignment = NSTextAlignmentLeft;
    agreeLabel.text = @"我已阅读并同意";
    agreeLabel.textColor = UIColorFromRGB(0xa2a2a2);
    [self.backgroundScrollView addSubview:agreeLabel];
    
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake(agreeLabel.frame.origin.x + agreeLabel.frame.size.width, agreeLabel.frame.origin.y + 1, 160.0f, 13.0f);
    agreeBtn.titleLabel.font = GENERAL_FONT13;
    [agreeBtn setTitle:@"《仁仁兼职平台用户协议》" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(agreeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:agreeBtn];
    
    // 设置滑动大小
    CGSize contsize = self.view.frame.size;
    contsize.height = self.okBtn.frame.origin.y + self.okBtn.frame.size.height + 10.0f;
    [self.backgroundScrollView setContentSize:contsize];
}

- (void)createWeakButtonsArr:(float)xOffset startY:(float)yOffset {
    
    [_dayButtonsArr removeAllObjects];
    float buttonSpacer = (_width - 30.0 - 4*_buttonWidth)/3;// 按钮之间的间隔距离 默认四个按钮为一行
    UIButton *buttonItem = nil;
    for (int index = 0; index < _daysArr.count; index++) {
        buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonItem setFrame:CGRectMake(xOffset + (index%4)*(_buttonWidth + buttonSpacer), yOffset + (index/4)*(10 + _buttonHeight), _buttonWidth, _buttonHeight)];
        [buttonItem setTitle:[_daysArr objectAtIndex:index] forState:UIControlStateNormal];
        buttonItem.titleLabel.textAlignment = NSTextAlignmentCenter;
        buttonItem.titleLabel.font = GENERAL_FONT14;
        buttonItem.tag = index + 1;
        buttonItem.layer.cornerRadius = 4.0f;
        buttonItem.layer.borderWidth = 1.0f;
        
        BOOL ishave = NO;
        for (NSString *dayId in _dayIdArr) {
            if ([dayId integerValue] == buttonItem.tag) {
                [buttonItem setTitleColor:UIColorFromRGB(0xfb6362) forState:UIControlStateNormal];
                CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
                CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.98f, 0.39f, 0.38f, 1});
                buttonItem.layer.borderColor = colorRef;
                
                ishave = YES;
            }
        }
        
        if (!ishave) {
            [buttonItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
            CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.95f, 0.95f, 0.95f, 1});
            buttonItem.layer.borderColor = colorRef;
        }
        
        [buttonItem addTarget:self action:@selector(weakButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundScrollView addSubview:buttonItem];
        
        [_dayButtonsArr addObject:buttonItem];
    }
}

- (void)createJobButtonsArr:(float)xOffset startY:(float)yOffset{
    
    [_jobButtonsArr removeAllObjects];
    float buttonSpacer = (_width - 30.0 - 4*_buttonWidth)/3;// 按钮之间的间隔距离 默认四个按钮为一行
    UIButton *buttonItem = nil;
    for (int index = 0; index < _jobsArr.count; index++) {
        buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonItem setFrame:CGRectMake(xOffset + (index%4)*(_buttonWidth + buttonSpacer), yOffset + (index/4)*(10 + _buttonHeight), _buttonWidth, _buttonHeight)];
        [buttonItem setTitle:[[_jobsArr objectAtIndex:index] objectForKey:@"name"] forState:UIControlStateNormal];
        buttonItem.titleLabel.textAlignment = NSTextAlignmentCenter;
        buttonItem.titleLabel.font = GENERAL_FONT14;
        buttonItem.tag = [[[_jobsArr objectAtIndex:index] objectForKey:@"id"] intValue];
        buttonItem.layer.cornerRadius = 4.0f;
        buttonItem.layer.borderWidth = 1.0f;
        
        BOOL ishave = NO;
        for (NSString *jobId in _jobIdArr) {
            if ([jobId integerValue] == buttonItem.tag) {
                [buttonItem setTitleColor:UIColorFromRGB(0xfb6362) forState:UIControlStateNormal];
                CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
                CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.98f, 0.39f, 0.38f, 1});
                buttonItem.layer.borderColor = colorRef;
                
                ishave = YES;
            }
        }
        
        if (!ishave) {
            [buttonItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
            CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.95f, 0.95f, 0.95f, 1});
            buttonItem.layer.borderColor = colorRef;
        }
        
        [buttonItem addTarget:self action:@selector(jobsButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.backgroundScrollView addSubview:buttonItem];
        
        [_jobButtonsArr addObject:buttonItem];
    }
}

- (void)updateOkbtn:(BOOL)enabled {
    self.okBtn.enabled = enabled;
    if (enabled) {
        self.okBtn.backgroundColor = [CommonVariable redBackgroundColor];
    }else {
        self.okBtn.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma  mark 数据处理

- (void)getAllJobsList {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters =[NSDictionary dictionary];
    [manager GET:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_JOBS_TYPE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _jobsArr = [[jsonData objectForKey:@"data"] mutableCopy];
            [self initUI];
        }else{
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];

}

- (void)postJobsInfo:(NSString *)day jobsInfo:(NSString *)info {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"uid":userId,
                                 @"job_time":day,
                                 @"intent":info};
    [AppUtils showLoadIng];
    [self updateOkbtn:NO];
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, POST_JOBS_INFO_INTENT] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self updateOkbtn:YES];
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@"兼职意向提交成功"];
            [self handlePostSuccess];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        [self updateOkbtn:YES];
    }];
}

- (void)handlePostSuccess {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:self.theViewClass]) {
            [AppUtils popToPage:self targetVC:controller];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_JOBSETTING_OK object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_ONLY_PARTTIME_DATA object:nil];
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)handleButtonStatus:(UIButton *)button theArr:(NSMutableArray *)arr {
    
    NSString *dayId = [NSString stringWithFormat:@"%d", (int)button.tag];
    if (arr.count == 0) {
        [button setTitleColor:UIColorFromRGB(0xfb6362) forState:UIControlStateNormal];
        CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.98f, 0.39f, 0.38f, 1});
        button.layer.borderColor = colorRef;
        [arr addObject:dayId];
    }else{
        
        BOOL isNew = YES;
        for (int index = 0; index < arr.count; index++) {
            NSString *tempId = [arr objectAtIndex:index];
            if ([tempId isEqual:dayId]) {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
                CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.95f, 0.95f, 0.95f, 1});
                button.layer.borderColor = colorRef;
                isNew = NO;
                [arr removeObjectAtIndex:index]; break;
            }
        }
        
        if (isNew) {
            [button setTitleColor:UIColorFromRGB(0xfb6362) forState:UIControlStateNormal];
            CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceRGB();
            CGColorRef colorRef = CGColorCreate(colorSapce, (CGFloat[]){0.98f, 0.39f, 0.38f, 1});
            button.layer.borderColor = colorRef;
            [arr addObject:dayId];
        }
        
    }
}

- (void)weakButton:(UIButton *)button {
    
    [self handleButtonStatus:button theArr:_dayIdArr];
}

- (void)jobsButton:(UIButton *)button {
    
    [self handleButtonStatus:button theArr:_jobIdArr];
}


- (void)okButton:(UIButton *)button {
    
    if (self.isAgree == NO) {
        [AppUtils showLoadInfo:@"请阅读仁仁兼职平台协议"];
        return;
    }
    
    NSString *dayStr = [self getStringFromArr:_dayIdArr];
    NSString *jobStr = [self getStringFromArr:_jobIdArr];
    
    if ([dayStr isEqual:@""]) {
        [AppUtils showLoadInfo:@"请选择兼职时间"];
    }else if ([jobStr isEqual:@""]) {
        [AppUtils showLoadInfo:@"请选择兼职工作意向"];
    }else{
        [self postJobsInfo:dayStr jobsInfo:jobStr];
    }
}

- (NSString *)getStringFromArr:(NSMutableArray *)arr {
    NSString *str = @"";
    if (arr.count == 1) {
        str = [arr objectAtIndex:0];
    }else if (arr.count > 1){
        str = [arr objectAtIndex:0];
        for (int index = 1; index < arr.count; index++) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"|%@", [arr objectAtIndex:index]]];
        }
    }
    return str;
}

- (void)agreeImageBtn:(UIButton *)button {
    self.isAgree = !self.isAgree;
    if (self.isAgree) {
        [self.agreeBtn setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_h"] forState:UIControlStateNormal];
    }
    else
    {
        [self.agreeBtn setBackgroundImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_n"] forState:UIControlStateNormal];
    }
}

- (void)agreeButton:(UIButton *)button {
    CommonWebViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
    vc.url = URL_PARTIME_JOB;
    vc.titleString= @"兼职平台协议";
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
