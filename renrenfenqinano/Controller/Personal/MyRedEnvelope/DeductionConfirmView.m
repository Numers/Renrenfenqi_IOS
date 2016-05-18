//
//  DeductionConfirmView.m
//  renrenfenqi
//
//  Created by DY on 14/11/28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "DeductionConfirmView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppUtils.h"

#define ConfirmViewWidth 290.0f
#define ConfirmViewHeight 120.0f

@interface DeductionConfirmView ()

@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confiremBtn;
@property (nonatomic, strong) UIView *backgroundView;// 用于灰色半透明

@end

@implementation DeductionConfirmView

- (id)initWithData:(int)deduction
{
    if (self = [super init]){
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 15, 240, 15)];
        self.moneyLabel.font = GENERAL_FONT15;
        self.moneyLabel.textColor = [UIColor blackColor];
        self.moneyLabel.textAlignment = NSTextAlignmentLeft;
        self.moneyLabel.text = [NSString stringWithFormat:@"抵扣本期还款额：￥%d",deduction];
        [self addSubview:self.moneyLabel];
        
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, self.moneyLabel.frame.origin.y + self.moneyLabel.frame.size.height + 6.0, 240, 15)];
        self.infoLabel.font = GENERAL_FONT15;
        self.infoLabel.textColor = [UIColor blackColor];
        self.infoLabel.textAlignment = NSTextAlignmentLeft;
        self.infoLabel.text = @"红包将被继续使用";
        [self addSubview:self.infoLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, self.infoLabel.frame.origin.y + self.infoLabel.frame.size.height + 15.0, ConfirmViewWidth-30, 0.5f)];
        line.backgroundColor = UIColorFromRGB(0xe0e0e0);
        [self addSubview:line];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelBtn.frame = CGRectMake(25.0, line.frame.origin.y + line.frame.size.height + 15, 36.0f, 18.0f);
        self.cancelBtn.backgroundColor = [UIColor clearColor];
        self.cancelBtn.titleLabel.font = GENERAL_FONT18;
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelBtn];
        
        self.confiremBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.confiremBtn.frame = CGRectMake(ConfirmViewWidth - 65.0f, line.frame.origin.y + line.frame.size.height + 15, 36.0f, 18.0f);
        self.confiremBtn.backgroundColor = [UIColor clearColor];
        self.confiremBtn.titleLabel.font = GENERAL_FONT18;
        [self.confiremBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.confiremBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.confiremBtn addTarget:self action:@selector(confirem:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.confiremBtn];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return self;
}

- (void)show
{
    UIViewController *topVC = [self appRootViewController];
    self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - ConfirmViewWidth) * 0.5, - ConfirmViewHeight - 30, ConfirmViewWidth, ConfirmViewHeight);
    [topVC.view addSubview:self];
}


- (void)dismiss:(UIButton *)sender
{
    [self removeFromSuperview];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)confirem:(UIButton *)sender
{
    [self removeFromSuperview];
    if (self.confirmBlock) {
        self.confirmBlock();
    }
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

- (void)removeFromSuperview
{
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    UIViewController *topVC = [self appRootViewController];
    CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - self.frame.size.width) * 0.5, CGRectGetHeight(topVC.view.bounds), self.frame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
        self.transform = CGAffineTransformMakeRotation(M_1_PI / 1.5);
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIViewController *topVC = [self appRootViewController];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.6f;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    [topVC.view addSubview:self.backgroundView];
    self.transform = CGAffineTransformMakeRotation(-M_1_PI / 2);
      CGRect afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - ConfirmViewWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - ConfirmViewHeight) * 0.5, ConfirmViewWidth, ConfirmViewHeight);
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = afterFrame;
    } completion:^(BOOL finished) {
        [super willMoveToSuperview:newSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
