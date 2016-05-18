//
//  RFSelectBookTimeViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/26.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFSelectBookTimeViewController.h"
#import "Student.h"
#import "RFDataPickViewController.h"
#import "RFDatePickViewController.h"

#define SelectDateIdentify @"SelectDateIdentify"
#define SelectTimeIdentify @"SelectTimeIdentify"
@interface RFSelectBookTimeViewController ()<RFDataPickViewProtocol,RFDatePickViewProtocol>
{
    Student *currentStudent;
    NSString *selectDateString;
    NSString *selectTimeString;
    NSArray *timeArray;
    
    RFDataPickViewController *rfDataPickView;
    RFDatePickViewController *rfDatePickView;
}
@property(nonatomic, strong) IBOutlet UIView *backView;
@property(nonatomic, strong) IBOutlet UIButton *btnComfirm;
@property(nonatomic, strong) IBOutlet UIButton *btnSelectDate;
@property(nonatomic, strong) IBOutlet UIButton *btnSelectTime;
@end

@implementation RFSelectBookTimeViewController
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
    [self.backView.layer setCornerRadius:5.0f];
    [self.backView.layer setMasksToBounds:YES];
    
    [self.btnComfirm.layer setCornerRadius:5.0f];
    [self.btnComfirm.layer setMasksToBounds:YES];
    
    timeArray = @[@"9:00-10:00",@"10:00-11:40",@"11:40-14:30",@"14:30-16:20",@"16:20-18:00",@"18:00-20:00",@"20:00-22:00"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUIView
{
    if (selectDateString) {
        [_btnSelectDate setTitle:selectDateString forState:UIControlStateNormal];
        [_btnSelectDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnSelectDate setTitle:@"请选择视频认证的日期" forState:UIControlStateNormal];
        [_btnSelectDate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if (selectTimeString) {
        [_btnSelectTime setTitle:selectTimeString forState:UIControlStateNormal];
        [_btnSelectTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnSelectTime setTitle:@"请选择合适的时间段" forState:UIControlStateNormal];
        [_btnSelectTime setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

-(BOOL)validateInput
{
    UIAlertView *alert = nil;
    if (selectDateString == nil || selectDateString.length == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择视频认证的日期" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if (!selectTimeString || selectTimeString.length == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择合适的时间段" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

-(IBAction)clickSelectDateBtn:(id)sender
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] + 24*60*60.0f;
    NSTimeInterval endTime = nowTime + 3*24*60*60.0f;
    rfDatePickView = [[RFDatePickViewController alloc] initWithDate:nowTime WithStartTime:nowTime WithEndTime:endTime WithPickViewIdentify:SelectDateIdentify];
    rfDatePickView.delegate = self;
    [rfDatePickView setDatePickMode:UIDatePickerModeDate];
    [rfDatePickView showInView:self.view];
}

-(IBAction)clickSelectTimeBtn:(id)sender
{
    if (timeArray) {
        rfDataPickView = [[RFDataPickViewController alloc] initWithDataArray:timeArray WithTitleArray:timeArray WithIdentify:SelectTimeIdentify];
        rfDataPickView.delegate = self;
        [rfDataPickView showInView:self.view];
    }
}

-(IBAction)clickComfirmBtn:(id)sender
{
    if([self validateInput]){
        currentStudent.videoTime = [NSString stringWithFormat:@"%@ %@",selectDateString,selectTimeString];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark RFDataPickViewProtocol
-(void)pickData:(id)data WithIdentify:(id)identify
{
    if ([identify isEqual:SelectTimeIdentify]) {
        selectTimeString = data;
        [self updateUIView];
    }
}

#pragma -mark RFDatePickViewProtocol
-(void)pickDate:(NSDate *)date WithIdentify:(id)identify
{
    if ([identify isEqual:SelectDateIdentify]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        selectDateString = [formatter stringFromDate:date];
        [self updateUIView];
    }
}

@end
