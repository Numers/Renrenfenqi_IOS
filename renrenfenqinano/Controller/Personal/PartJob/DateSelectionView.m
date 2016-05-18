//
//  dateSelectionView.m
//  renrenfenqi
//
//  Created by DY on 14/12/26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "DateSelectionView.h"
#import "AppUtils.h"

#define dateViewHeight 250.0f

@implementation DateSelectionView

- (id)initDateView {
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.opacity = 0.95;
        UIViewController *topVC = [self appRootViewController];
        CGRect frame = topVC.view.frame;
        frame.origin.y = frame.size.height;
        frame.size.height = dateViewHeight;
        self.frame = frame;
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5f)];
        line1.backgroundColor = [UIColor grayColor];
        [self addSubview:line1];

        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(15, 10.0, 40, 20);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCancel.titleLabel.font = GENERAL_FONT15;
        [btnCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCancel];
        
        UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOk.frame = CGRectMake(self.frame.size.width - 40 -15.0f, 10.0, 40, 20);
        [btnOk setTitle:@"确认" forState:UIControlStateNormal];
        [btnOk setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnOk.titleLabel.font = GENERAL_FONT15;
        [btnOk addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnOk];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, btnCancel.frame.size.height + btnCancel.frame.origin.y + 10 , self.frame.size.width, 0.5f)];
        line2.backgroundColor = [UIColor grayColor];
        [self addSubview:line2];
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 216.0f, self.frame.size.width, 216.0f)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"];
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
        self.currentDate = self.datePicker.date;
        [self addSubview:self.datePicker];
    }
    
    return self;
}

- (void)show{
    
    UIViewController *topVC = [self appRootViewController];
    CGRect frame = topVC.view.frame;
    frame.origin.y = frame.size.height - dateViewHeight;
    frame.size.height = dateViewHeight;
    self.frame = frame;
    
    [topVC.view addSubview:self];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = 0.2;
    animation.fromValue = [NSNumber numberWithFloat:topVC.view.frame.size.height + 0.5*self.frame.size.height];
    animation.toValue = [NSNumber numberWithFloat:topVC.view.frame.size.height - 0.5*self.frame.size.height];
    animation.removedOnCompletion=YES;
    [self.layer addAnimation:animation forKey:@"showDialogAnimation"];
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)dismiss {
    
    UIViewController *topVC = [self appRootViewController];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = 0.2;
    animation.fromValue = [NSNumber numberWithFloat:topVC.view.frame.size.height - 0.5*self.frame.size.height];
    animation.toValue = [NSNumber numberWithFloat:topVC.view.frame.size.height + 0.5*self.frame.size.height];
    animation.removedOnCompletion=YES;
    [animation setDelegate:self];
    [self.layer addAnimation:animation forKey:@"hideDialogAnimation"];
    
    [self performSelector:@selector(delayOpacityToZero:) withObject:self.layer afterDelay:0.13];
}

// 延迟设置透明度为0
- (void)delayOpacityToZero:(id)sender
{
    // 防止在窗口消息时闪烁一下
    self.layer.transform = CATransform3DMakeScale(0, 0, 1);
    
    CALayer *layer = sender;
    [layer setOpacity:0.0];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
    
    [self removeFromSuperview];
}

- (void)ok {
    
    if ([self.delegate respondsToSelector:@selector(saveDate:)]) {
        [self.delegate saveDate:self.currentDate];
    }
    [self dismiss];
}

-(void)dateChanged:(UIDatePicker *)sender{
    self.currentDate = sender.date;
    NSLog(@"%@", self.currentDate);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
