//
//  RFStudentAutheticationScrollViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFStudentAutheticationScrollViewController.h"
#import "RFStudentAutheticationViewController.h"
#import "Student.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "RFDataPickViewController.h"
#import "RFAuthManager.h"
#import "AppUtils.h"

#define EducationLevelIdentify @"EducationLevel"
#define GraduationYearIdentify @"GraduationYear"
@interface RFStudentAutheticationScrollViewController ()<RFStudentAutheticationViewProtocol,RFDataPickViewProtocol>
{
    RFStudentAutheticationViewController *rfStudentAutheticationVC;
    TPKeyboardAvoidingScrollView *scrollView;
    
    Student *currentStudent;
    
    RFDataPickViewController *dataPickView;
    NSArray *educationLevelList;
    NSMutableArray *graduationYearsList;
    NSMutableArray *graduationYearsTitleList;
}
@end

@implementation RFStudentAutheticationScrollViewController
-(id)initWithStudent:(Student *)student
{
    self = [super init];
    if (self) {
        currentStudent = student;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:scrollView];
    rfStudentAutheticationVC = [[RFStudentAutheticationViewController alloc] initWithStudent:currentStudent];
    rfStudentAutheticationVC.delegate = self;
    NSLog(@"%f,%f,%f,%f",rfStudentAutheticationVC.view.frame.origin.x,rfStudentAutheticationVC.view.frame.origin.y,rfStudentAutheticationVC.view.frame.size.width,rfStudentAutheticationVC.view.frame.size.height);
    [scrollView addSubview:rfStudentAutheticationVC.view];
    [scrollView setContentSize:rfStudentAutheticationVC.view.frame.size];
    
    educationLevelList = @[@"本科",@"专科",@"硕士研究生",@"博士研究生"];
    NSDate *now = [NSDate date];
    NSInteger currentYear = [self yearFromDate:now];
    graduationYearsList = [[NSMutableArray alloc] init];
    graduationYearsTitleList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i <= 7; i++) {
        NSNumber *num = [NSNumber numberWithInteger:currentYear+i];
        [graduationYearsList addObject:num];
        NSString *title = [NSString stringWithFormat:@"%ld年",(long)(currentYear+i)];
        [graduationYearsTitleList addObject:title];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)yearFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSInteger year = [dateComponent year];
    return year;
}

#pragma -mark RFStudentAutheticationViewProtocol
-(void)clickBackBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickNextBtn
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    NSString *token = [loginInfo objectForKey:@"token"];
    if ([AppUtils isLogined:uid]) {
        if ([currentStudent.uid isEqualToString:uid]) {
            [[RFAuthManager defaultManager] updateStudentInfomationWithStudent:currentStudent WithToken:token Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }
}

-(void)clickSelectEducationLevelBtn
{
    dataPickView = [[RFDataPickViewController alloc] initWithDataArray:educationLevelList WithTitleArray:educationLevelList WithIdentify:EducationLevelIdentify];
    if (currentStudent.educationLevel && currentStudent.educationLevel.length > 0) {
        if ([educationLevelList containsObject:currentStudent.educationLevel]) {
            NSInteger row = [educationLevelList indexOfObject:currentStudent.educationLevel];
            [dataPickView setSelectRow:row];
        }
    }
    dataPickView.delegate = self;
    [dataPickView showInView:self.view];
}

-(void)clickSelectGraduationBtn
{
    dataPickView = [[RFDataPickViewController alloc] initWithDataArray:graduationYearsList WithTitleArray:graduationYearsTitleList WithIdentify:GraduationYearIdentify];
    if (currentStudent.graduationYear > 0) {
        NSNumber *graduateYear = [NSNumber numberWithInteger:currentStudent.graduationYear];
        if ([graduationYearsList containsObject:graduateYear]) {
            NSInteger row = [graduationYearsList indexOfObject:graduateYear];
            [dataPickView setSelectRow:row];
        }
    }
    dataPickView.delegate = self;
    [dataPickView showInView:self.view];
}

-(void)clickSelectSchoolBtn
{
    
}

#pragma -mark RFDataPickViewProtocol
-(void)pickData:(id)data WithIdentify:(id)identify
{
    if ([identify isEqual:EducationLevelIdentify]) {
        currentStudent.educationLevel = data;
    }
    
    if ([identify isEqual:GraduationYearIdentify]) {
        currentStudent.graduationYear = [data integerValue];
    }
    [rfStudentAutheticationVC setViewInputValue];
}
@end
