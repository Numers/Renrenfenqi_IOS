//
//  JobDetailViewController2.m
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "JobDetailViewController2.h"
#import "CommonTools.h"
#import "CommonVariable.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "UserLoginViewController.h"
#import "ImprovePersonalInfoViewController.h"
#import "ImprovePersonalInfoViewController2.h"
#import "MyJobsViewController2.h"

@interface JobDetailViewController2 ()
{
    float _defaultTitleViewHeight;
    float _defaultDescriptionViewHeight;
    float _defaultCapacityViewHeight;
    float _defaultButtonHeight;
    float _defaultButtonViewHeight;
    int   _defaultCapacityCount;
    float _titleInfoIconSide;
    
    CGSize _rectangleSize;
    
    NSMutableArray *_infoLabelArr;        // 兼职描述label容器
    NSMutableArray *_capacityLabelArr;    // 能力值label容器
    NSMutableArray *_capacityRectangleArr;// 能力值 方块图形容器
    NSMutableArray *_capacityValueArr;    // 能力值
    NSDictionary   *_jobDetailInfo;
    
    UIStoryboard   *_mainStoryboard;
    NSMutableDictionary *_myjobSetting;
}

@property (strong, nonatomic) UIScrollView *mainView;  // 主界面

@property (strong, nonatomic) UIView *topView;         // 导航界面
@property (strong, nonatomic) UIView *titleView;       // 兼职标题界面
@property (strong, nonatomic) UIView *descriptionView; // 兼职详情描述界面
@property (strong, nonatomic) UIView *capacityView;    // 能力值界面

@property (strong, nonatomic) UILabel *titleLabel;           // 兼职标题
@property (strong, nonatomic) UILabel *areaLabel;            // 兼职区域
@property (strong, nonatomic) UILabel *createDateLabel;      // 兼职发布时间
@property (strong, nonatomic) UILabel *platformTypeLabel;    // 发布平台
@property (strong, nonatomic) UIImageView *areaImageView;
@property (strong, nonatomic) UIImageView *createDateImageView;
@property (strong, nonatomic) UIImageView *platformTypeImageView;

@property (strong, nonatomic) UIButton *requestBtn;
@property (strong, nonatomic) UIView   *descriptionViewBottomLine;// 兼职描述界面底部灰线

@end

@implementation JobDetailViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    /* 右滑返回 下个版本添加
     UIGestureRecognizerDelegate
     self.navigationController.interactivePopGestureRecognizer.enabled = YES;
     self.navigationController.interactivePopGestureRecognizer.delegate = self;
     */
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobDetailInfo) name:UPDATE_JOB_DETAIL object:nil];
    // 初始化本界面数据
    [self initViewData];
    // 初始化UI
    [self initUI];
    // 获取兼职详情
    [self requestJobDetailInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateJobDetailInfo{
    [self requestJobDetailInfo];
}

- (void)initViewData {
    _defaultTitleViewHeight = 70.0f;
    _defaultDescriptionViewHeight = 180.0f;
    _defaultCapacityViewHeight = 145.0f;
    _defaultButtonViewHeight = 50.0f;
    _defaultButtonHeight = 35.0f;
    _titleInfoIconSide = 15.0f;// 标题栏 下面的地点等图标的边长
    _defaultCapacityCount = 3;
    _rectangleSize = CGSizeMake(30.0f*_MainScreen_Width/320.0f, 10.0f);
    
    _infoLabelArr = [NSMutableArray array];
    _capacityLabelArr = [NSMutableArray array];
    _capacityRectangleArr = [NSMutableArray array];
    _capacityValueArr = [NSMutableArray array];
    _jobDetailInfo = [NSDictionary dictionary];
    
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _myjobSetting = [NSMutableDictionary dictionary];
}

#pragma mark 数据获取
- (void)requestJobDetailInfo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    NSDictionary *parameters = @{@"id":self.jobId, @"students_id":userId};
    
    [AppUtils showLoadIng:@"兼职详情获取中..."];
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_JOB_DETAIL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            _jobDetailInfo = [[jsonData objectForKey:@"data"] copy];
            [self refreshJobDetail];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)requestParttimeInfo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    
    NSDictionary *parameters = @{@"uid":userId};
    [AppUtils showLoadIng];
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            _myjobSetting = [jsonData objectForKey:@"data"];
            if ([[_myjobSetting objectForKey:@"is_info"] intValue] == 0) {
                ImprovePersonalInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
                vc.isSkip = NO;
                vc.theViewClass = [JobDetailViewController2 class];
                [AppUtils pushPage:self targetVC:vc];
            }else if ([[_myjobSetting objectForKey:@"state"] intValue] == 0) {
                ImprovePersonalInfoViewController2 *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
                vc.theViewClass = [JobDetailViewController2 class];
                [AppUtils pushPage:self targetVC:vc];
            }else {
                [self submitToApplyJob];
            }

        }else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
            [self updateRequestBtn:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        [self updateRequestBtn:YES];
    }];
}

- (void)submitToApplyJob {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    NSDictionary *parameters = @{@"students_id":userId,
                                 @"job_id":self.jobId,
                                 @"title":[AppUtils readAPIField:_jobDetailInfo key:@"title"],
                                 @"school":[AppUtils readAPIField:_myjobSetting key:@"school_name"],
                                 @"uname":[AppUtils readAPIField:_myjobSetting key:@"name"],
                                 @"mobile":[AppUtils readAPIField:_myjobSetting key:@"phone"]
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, APPLY_JOB] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self updateRequestBtn:NO];
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"兼职申请成功" message:@"请等候客服人员联系您！想了解最新兼职回复，请至“我的”→“我的兼职”查看 " delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去看看",nil];
            [msgbox show];
        }else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
            [self updateRequestBtn:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        [self updateRequestBtn:YES];
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString* btn = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btn isEqualToString:@"去看看"]) {
        MyJobsViewController2 *vc = [[MyJobsViewController2 alloc] init];
        [AppUtils pushPage:self targetVC:vc];
    }
}


#pragma mark 界面处理
- (void)initUI {
    // 创建导航界面
    self.topView = [CommonTools generateTopBarWiwhOnlyBackButton:self title:@"兼职详情" action:@selector(back:)];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    // 创建背景图
    self.mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height -(self.topView.frame.origin.y + self.topView.frame.size.height + _defaultButtonViewHeight))];
    self.mainView.backgroundColor = [CommonVariable grayBackgroundColor];
    [self.view addSubview:self.mainView];
    // 初始化兼职详情标题界面
    [self initTitleViewUI];
    // 初始化兼职详情描述界面
    [self initDescriptionViewUI];
    // 初始化兼职详情奖励能力值界面
    [self initCapacityViewUI];
    // 发送按钮界面
    [self initButtonViewUI];
}
// 初始化标题界面
- (void)initTitleViewUI {
    self.titleView = [[UIView alloc] init];
    self.titleView.frame = CGRectMake(0, 0, self.mainView.frame.size.width, _defaultTitleViewHeight);
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:self.titleView];
    
    UIView *bottomline = [[UIView alloc] init];
    bottomline.frame = CGRectMake(0, self.titleView.frame.size.height - 0.5f, self.titleView.frame.size.width, 0.5f);
    bottomline.backgroundColor = [CommonVariable grayLineColor];
    [self.titleView addSubview:bottomline];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.titleView addSubview:self.titleLabel];
    
    self.areaImageView = [[UIImageView alloc] init];
    self.areaImageView.image = [UIImage imageNamed:@"partdetail_body_adress_n@2x.png"];
    [self.titleView addSubview:self.areaImageView];
    
    self.areaLabel = [[UILabel alloc] init];
    self.areaLabel.font = GENERAL_FONT13;
    self.areaLabel.textColor = UIColorFromRGB(0x8d8d8d);
    self.areaLabel.textAlignment = NSTextAlignmentLeft;
    [self.titleView addSubview:self.areaLabel];
    
    self.createDateImageView = [[UIImageView alloc] init];
    self.createDateImageView.image = [UIImage imageNamed:@"partdetail_body_time_n@2x.png"];
    [self.titleView addSubview:self.createDateImageView];
    
    self.createDateLabel = [[UILabel alloc] init];
    self.createDateLabel.font = GENERAL_FONT13;
    self.createDateLabel.textColor = UIColorFromRGB(0x8d8d8d);
    self.createDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:self.createDateLabel];
    
    self.platformTypeLabel = [[UILabel alloc] init];
    self.platformTypeLabel.font = GENERAL_FONT13;
    self.platformTypeLabel.textColor = UIColorFromRGB(0x8d8d8d);
    self.platformTypeLabel.textAlignment = NSTextAlignmentRight;
    self.platformTypeLabel.text = @"自营";
    [self.titleView addSubview:self.platformTypeLabel];
    
    self.platformTypeImageView = [[UIImageView alloc] init];
    self.platformTypeImageView.image = [UIImage imageNamed:@"partdetail_body_self_n@2x.png"];
    [self.titleView addSubview:self.platformTypeImageView];
}
// 初始化兼职描述界面
- (void)initDescriptionViewUI {
    self.descriptionView = [[UIView alloc] init];
    self.descriptionView.frame = CGRectMake(0, self.titleView.frame.origin.y + self.titleView.frame.size.height + 10.0f, self.mainView.frame.size.width, _defaultDescriptionViewHeight);
    self.descriptionView.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:self.descriptionView];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.frame = CGRectMake(0, 0, self.descriptionView.frame.size.width, 0.5f);
    topLine.backgroundColor = [CommonVariable grayLineColor];
    [self.descriptionView addSubview:topLine];
    
    self.descriptionViewBottomLine = [[UIView alloc] init];
    self.descriptionViewBottomLine.backgroundColor = [CommonVariable grayLineColor];
    [self.descriptionView addSubview:self.descriptionViewBottomLine];
    
    UIImageView *tipsImageView = [[UIImageView alloc] init];
    tipsImageView.frame = CGRectMake(15.0f, 0.5f, 55.0f, 17.0f);
    tipsImageView.image = [UIImage imageNamed:@"partdetail_body_description_n@2x.png"];
    [self.descriptionView addSubview:tipsImageView];
    
    if (_infoLabelArr.count > 0) {
        [_infoLabelArr removeAllObjects];
    }
    NSArray *textArr = @[@"发布商家：", @"工作地址：", @"工作时间：", @"工资待遇：", @"其他说明："];
    UILabel *label = nil;
    UILabel *infoLabel = nil;
    for (int index = 0; index < textArr.count; index++) {
        label = [[UILabel alloc] init];
        label.font = GENERAL_FONT14;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = [NSString stringWithFormat:@"%@",[textArr objectAtIndex:index]];
        CGSize textsize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        float yoffset = tipsImageView.frame.origin.y + tipsImageView.frame.size.height + 12.0f + index*(textsize.height + 15.0f);
        label.frame = CGRectMake(15.0f, yoffset, textsize.width, textsize.height);
        [self.descriptionView addSubview:label];
        
        infoLabel = [[UILabel alloc] init];
        infoLabel.font = GENERAL_FONT14;
         infoLabel.numberOfLines = 1;
        infoLabel.textColor = UIColorFromRGB(0x787878);
        infoLabel.textAlignment = NSTextAlignmentLeft;
        if (index == 4) {
            infoLabel.numberOfLines = 0;
        }else if (index == 3) {
            infoLabel.textColor = [CommonVariable redFontColor];
        }
        infoLabel.frame = CGRectMake(label.frame.origin.x + label.frame.size.width + 5.0f, label.frame.origin.y, self.descriptionView.frame.size.width - (label.frame.origin.x + label.frame.size.width + 20.0f), textsize.height);
        [self.descriptionView addSubview:infoLabel];
        [_infoLabelArr addObject:infoLabel];
    }
}
// 初始化技能界面
- (void)initCapacityViewUI {
    self.capacityView = [[UIView alloc] init];
    self.capacityView.frame = CGRectMake(0, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height + 10.0f, self.mainView.frame.size.width, _defaultCapacityViewHeight);
    self.capacityView.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:self.capacityView];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.frame = CGRectMake(0, 0, self.capacityView.frame.size.width, 0.5f);
    topLine.backgroundColor = [CommonVariable grayLineColor];
    [self.capacityView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.frame = CGRectMake(0, self.capacityView.frame.size.height - 0.5f, self.capacityView.frame.size.width, 0.5f);
    bottomLine.backgroundColor = [CommonVariable grayLineColor];
    [self.capacityView addSubview:bottomLine];
    
    UIImageView *tipsImageView = [[UIImageView alloc] init];
    tipsImageView.frame = CGRectMake(15.0f, 0.5f, 55.0f, 17.0f);
    tipsImageView.image = [UIImage imageNamed:@"partdetail_body_skill_n@2x.png"];
    [self.capacityView addSubview:tipsImageView];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = GENERAL_FONT14;
    tipsLabel.textColor = [CommonVariable grayFontColor];
    tipsLabel.textAlignment = NSTextAlignmentLeft;
    tipsLabel.text = @"成功兼职后，个人能力值将获得如下提高：";
    CGSize textSize = [tipsLabel.text sizeWithAttributes:@{NSFontAttributeName:tipsLabel.font}];
    tipsLabel.frame = CGRectMake(15.0f, tipsImageView.frame.origin.y + tipsImageView.frame.size.height+12.0f, self.capacityView.frame.size.width - 30.0f, textSize.height);
    [self.capacityView addSubview:tipsLabel];
    
    if (_capacityLabelArr.count > 0) {
        [_capacityLabelArr removeAllObjects];
    }
    if (_capacityValueArr.count > 0) {
        [_capacityValueArr removeAllObjects];
    }
    
    textSize = [@"沟通力" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT14}];
    for (int index = 0; index < _defaultCapacityCount; index++) {
        float yoffset = tipsLabel.frame.origin.y + tipsLabel.frame.size.height + 15.0f + index*(textSize.height + 10.0f);
        UILabel *label = [[UILabel alloc] init];
        label.font = GENERAL_FONT14;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.frame = CGRectMake(15.0f, yoffset, textSize.width, textSize.height);
        [self.capacityView addSubview:label];
        [_capacityLabelArr addObject:label];
        
        for (int rectangleIndex = 0; rectangleIndex < 5; rectangleIndex++) {
            float xoffset = label.frame.origin.x + label.frame.size.width + 10.0f + rectangleIndex*(_rectangleSize.width + 1.0f);
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = UIColorFromRGB(0xf9f0f1);
            view.tag = 10*index + rectangleIndex + 1;
            view.frame = CGRectMake(xoffset, yoffset + 0.5*(textSize.height - _rectangleSize.height) + 1.0f, _rectangleSize.width, _rectangleSize.height);
            [self.capacityView addSubview:view];
            [_capacityRectangleArr addObject:view];
            
            if (rectangleIndex == 4) {
                UILabel *valueLabel = [[UILabel alloc] init];
                valueLabel.font = GENERAL_FONT14;
                valueLabel.textColor = [CommonVariable grayFontColor];
                valueLabel.textAlignment = NSTextAlignmentCenter;
                valueLabel.frame = CGRectMake(view.frame.origin.x + view.frame.size.width, label.frame.origin.y, textSize.width, textSize.height);
                [self.capacityView addSubview:valueLabel];
                [_capacityValueArr addObject:valueLabel];
            }
        }
    }
}
// 初始化底部按钮界面
- (void)initButtonViewUI {
    UIView *buttonBackView = [[UIView alloc] init];
    buttonBackView.backgroundColor = [UIColor whiteColor];
    buttonBackView.frame = CGRectMake(0, self.view.frame.size.height - _defaultButtonViewHeight, self.view.frame.size.width, _defaultButtonViewHeight);
    [self.view addSubview:buttonBackView];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [CommonVariable grayLineColor];
    topLine.frame = CGRectMake(0, 0, buttonBackView.frame.size.width, 0.5f);
    [buttonBackView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [CommonVariable grayLineColor];
    bottomLine.frame = CGRectMake(0, buttonBackView.frame.size.height - 0.5f, buttonBackView.frame.size.width, 0.5f);
    [buttonBackView addSubview:bottomLine];
    
    self.requestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.requestBtn.frame = CGRectMake(15, (buttonBackView.frame.size.height - _defaultButtonHeight)/2, self.view.frame.size.width - 30.0f, _defaultButtonHeight);
    self.requestBtn.layer.cornerRadius = 4.0f;
    self.requestBtn.layer.masksToBounds = YES;
    self.requestBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.requestBtn setTitle:@"发送工作申请" forState:UIControlStateNormal];
    [self.requestBtn setTitle:@"已申请" forState:UIControlStateDisabled];
    [self.requestBtn addTarget:self action:@selector(requestJobs:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBackView addSubview:self.requestBtn];
}

- (void)refreshJobDetail {
    // 刷新头部信息栏
    [self refreshTitleView];
    // 刷新兼职描述
    [self refreshDescriptionView];
    // 刷新技能界面
    [self refreshCapacityView];
    // 刷新底部按钮界面
    [self refreshButtonView];
}
// 刷新标题界面
- (void)refreshTitleView {
    self.titleLabel.text = [AppUtils filterNull:[_jobDetailInfo objectForKey:@"title"]];
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    self.titleLabel.frame = CGRectMake(15.0f, 13.0f, self.titleView.frame.size.width - 30.0f, textSize.height);
    
    self.areaImageView.frame = CGRectMake(15.0f, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 13.0f, _titleInfoIconSide, _titleInfoIconSide);
    self.areaLabel.text = [AppUtils filterNull:[_jobDetailInfo objectForKey:@"region"]];
    textSize = [self.areaLabel.text sizeWithAttributes:@{NSFontAttributeName:self.areaLabel.font}];
    self.areaLabel.frame = CGRectMake(self.areaImageView.frame.origin.x + self.areaImageView.frame.size.width + 5.0f,self.areaImageView.frame.origin.y, 100.0f, textSize.height);
    
    textSize = [@"2015-02-02" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT13}];
    self.createDateImageView.frame = CGRectMake(0.5*(self.titleView.frame.size.width - textSize.width - _titleInfoIconSide - 5.0f), self.areaImageView.frame.origin.y, _titleInfoIconSide, _titleInfoIconSide);
    self.createDateLabel.text = [AppUtils filterNull:[[_jobDetailInfo objectForKey:@"ctime"] substringToIndex:10]];;
    self.createDateLabel.frame = CGRectMake(self.createDateImageView.frame.origin.x + self.createDateImageView.frame.size.width + 5.0f, self.createDateImageView.frame.origin.y, textSize.width, textSize.height);
    
    textSize = [self.platformTypeLabel.text sizeWithAttributes:@{NSFontAttributeName:self.platformTypeLabel.font}];
    self.platformTypeLabel.frame = CGRectMake(self.titleView.frame.size.width - 15.0f - textSize.width, self.areaLabel.frame.origin.y, textSize.width, textSize.height);
    self.platformTypeImageView.frame = CGRectMake(self.platformTypeLabel.frame.origin.x - (_titleInfoIconSide + 5.0f), self.createDateImageView.frame.origin.y, _titleInfoIconSide, _titleInfoIconSide);
}
// 刷新兼职描述界面
- (void)refreshDescriptionView {
    NSString *tempText = @"";
    for (int index = 0; index < _infoLabelArr.count; index++) {
        if (![[_infoLabelArr objectAtIndex:index] isKindOfClass:[UILabel class]]) {
            break;
        }
        UILabel *label = [_infoLabelArr objectAtIndex:index];
        if (index == 0) {
            tempText = [_jobDetailInfo objectForKey:@"bus_name"];
        }else if (index == 1) {
            tempText = [_jobDetailInfo objectForKey:@"address"];
        }else if (index == 2) {
            tempText = [_jobDetailInfo objectForKey:@"work_time"];
        }else if (index == 3) {
            tempText = [_jobDetailInfo objectForKey:@"wage"];
        }else if (index == 4) {
            tempText = [_jobDetailInfo objectForKey:@"info"];
        }
        label.text = [AppUtils filterNull:tempText];
        
        if (index == 4) {
            CGSize maxContentSize = CGSizeMake(label.frame.size.width, 800.0f);
            CGSize descriptionSize = [label.text boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size;
            CGRect tempFrame = label.frame;
            tempFrame.size.height = descriptionSize.height;
            label.frame = tempFrame;
            
            tempFrame = self.descriptionView.frame;
            tempFrame.size.height += descriptionSize.height;
            self.descriptionView.frame = tempFrame;
            
            self.descriptionViewBottomLine.frame = CGRectMake(0, self.descriptionView.frame.size.height - 0.5f, self.descriptionView.frame.size.width, 0.5f);
        }
    }
    
    self.capacityView.frame = CGRectMake(0, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height + 10.0f, self.mainView.frame.size.width, _defaultCapacityViewHeight);
    
    CGSize contentSize = self.mainView.frame.size;
    contentSize.height = self.titleView.frame.size.height + self.descriptionView.frame.size.height + self.capacityView.frame.size.height + 20.0f;
    self.mainView.contentSize = contentSize;
}
// 刷新技能界面
- (void)refreshCapacityView {
    NSArray *tempArr = [[_jobDetailInfo objectForKey:@"latitude_param"] mutableCopy];
    for (int index = 0; index < _capacityLabelArr.count; index ++) {
        if (![[_capacityLabelArr objectAtIndex:index] isKindOfClass:[UILabel class]]) {
            break;
        }
        UILabel *label = [_capacityLabelArr objectAtIndex:index];
        if (index < tempArr.count) {
            label.text = [AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"name"]];
        }
    }
    
    for (int index = 0; index < _capacityValueArr.count; index ++) {
        if (![[_capacityValueArr objectAtIndex:index] isKindOfClass:[UILabel class]]) {
            break;
        }
        UILabel *label = [_capacityValueArr objectAtIndex:index];
        if (index < tempArr.count) {
            label.text = [NSString stringWithFormat:@"+%@", [AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"num"]]];
            int value = [[[tempArr objectAtIndex:index] objectForKey:@"num"] intValue];
            UIColor *capacityColor = [self rectangleColorByCapacityName:[AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"name"]]];
            for (int i = 0; i < 5; i++) {
                if (5*index + i > _capacityRectangleArr.count) {
                    break;
                }
                
                if (![[_capacityRectangleArr objectAtIndex:index] isKindOfClass:[UIView class]]) {
                    break;
                }
                
                UIView *colorView = [_capacityRectangleArr objectAtIndex:5*index + i];
                if (i < value) {
                    colorView.backgroundColor = capacityColor;
                }else{
                    colorView.backgroundColor = UIColorFromRGB(0xf9f0f1);
                }
            }
        }
    }
}
// 刷新底部按钮界面
- (void)refreshButtonView {
    int requestStatus = [[_jobDetailInfo objectForKey:@"is_user"] intValue];
    if (requestStatus == 0) {
        [self updateRequestBtn:NO];
    }else{
        [self updateRequestBtn:YES];
    }
}

- (void)updateRequestBtn:(BOOL)isEnabled {
    self.requestBtn.enabled = isEnabled;
    if (isEnabled) {
        self.requestBtn.backgroundColor = [CommonVariable redBackgroundColor];
    }else{
        self.requestBtn.backgroundColor = [UIColor lightGrayColor];
    }
}

- (UIColor *)rectangleColorByCapacityName:(NSString *)capacityName {
    UIColor *tempColor = UIColorFromRGB(0xf9f0f1);
    if ([capacityName isEqual:@"经验值"]) {
        tempColor = UIColorFromRGB(0xafdff3);
    }else if ([capacityName isEqual:@"执行力"]) {
        tempColor = UIColorFromRGB(0xade9de);
    }else if ([capacityName isEqual:@"抗压性"]) {
        tempColor = UIColorFromRGB(0xfed7b0);
    }else if ([capacityName isEqual:@"沟通力"]) {
        tempColor = UIColorFromRGB(0xfeccd2);
    }else if ([capacityName isEqual:@"学习力"]) {
        tempColor = UIColorFromRGB(0xbeebb3);
    }else if ([capacityName isEqual:@"诚信值"]) {
        tempColor = UIColorFromRGB(0xf3cef7);
    }
    return tempColor;
}

#pragma mark 按钮响应

- (void)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

- (void)requestJobs:(UIButton *)sender {
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [AppUtils filterNull:[app.store getStringById:USER_ID fromTable:USER_TABLE]];
    
    if ([AppUtils isLogined:userId]) {
        [self updateRequestBtn:NO];
        [self requestParttimeInfo];
    }else{
        UserLoginViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        vc.writeInfoMode = WriteInfoModeOption;
        vc.parentClass = [JobDetailViewController2 class];
        [AppUtils pushPageFromBottomToTop:self targetVC:vc];
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
