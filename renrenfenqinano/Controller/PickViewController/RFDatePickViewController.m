//
//  RFDatePickViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFDatePickViewController.h"
#define ToolBarHeight 40.0f
#define Duration 0.3f
@interface RFDatePickViewController ()
{
    NSTimeInterval defaultDate;
    NSTimeInterval defaultStartTime;
    NSTimeInterval defaultEndTime;
    id pickViewIdentify;
    NSDate *selectDate;
    UIView *parentView;
    BOOL isShow;
    UIDatePickerMode selectMode;
}
@property(nonatomic, strong) UIDatePicker *pickView;
@property(nonatomic, strong) UIToolbar *toolBar;
@end

@implementation RFDatePickViewController
-(id)initWithDate:(NSTimeInterval)time WithStartTime:(NSTimeInterval)startTime WithEndTime:(NSTimeInterval)endTime WithPickViewIdentify:(id)identify
{
    self = [super init];
    if (self) {
        defaultDate = time;
        defaultStartTime = startTime;
        defaultEndTime = endTime;
        pickViewIdentify = identify;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpPickView];
    
    float viewHeight = _toolBar.frame.size.height + _pickView.frame.size.height;
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, viewHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpPickView
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ToolBarHeight)];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancelBtn)];
    [leftBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickComfirmBtn)];
    [rightBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    _toolBar.items=@[leftBarItem,centerSpace,rightBarItem];
    [self.view addSubview:_toolBar];
    
    _pickView = [[UIDatePicker alloc] init];
    [_pickView setFrame:CGRectMake(0, ToolBarHeight, [UIScreen mainScreen].bounds.size.width, _pickView.frame.size.height)];
    [_pickView setTimeZone:[NSTimeZone timeZoneWithName:@"GTM+8"]];
    [_pickView setMinimumDate:[NSDate dateWithTimeIntervalSince1970:defaultStartTime]];
    [_pickView setMaximumDate:[NSDate dateWithTimeIntervalSince1970:defaultEndTime]];
    [_pickView setDatePickerMode:selectMode];
    _pickView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    [_pickView addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pickView];
    selectDate = [NSDate dateWithTimeIntervalSince1970:defaultDate];
    [_pickView setDate:selectDate];
}

-(void)setDatePickMode:(UIDatePickerMode)mode
{
    selectMode = mode;
    if (_pickView) {
        [_pickView setDatePickerMode:mode];
    }
}

-(void)datePickerValueChange:(UIDatePicker *)sender
{
    selectDate = [sender date];
}

-(void)showInView:(UIView *)view
{
    CATransition *animation = [CATransition  animation];
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
    [view setUserInteractionEnabled:NO];
    parentView = view;
    isShow = YES;
}

-(void)hidden
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [parentView setUserInteractionEnabled:YES];
    [self performSelector:@selector(removeView) withObject:nil];
}

-(void)removeView
{
    [_toolBar removeFromSuperview];
    _toolBar = nil;
    
    [_pickView removeFromSuperview];
    _pickView = nil;
    
    [self.view removeFromSuperview];
}

-(BOOL)isShow
{
    return isShow;
}

-(void)clickCancelBtn
{
    [self hidden];
}

-(void)clickComfirmBtn
{
    if ([_delegate respondsToSelector:@selector(pickDate:WithIdentify:)]) {
        [_delegate pickDate:selectDate WithIdentify:pickViewIdentify];
    }
    [self hidden];
}
@end
