//
//  TakeRedPacketView.m
//  renrenfenqi
//
//  Created by DY on 14/11/27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "TakeRedPacketView.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

#define thRedViewWidth 310
#define theRedViewHeight 400

@interface TakeRedPacketView ()
{
    NSMutableArray *_cardsButton;
    CGRect _tempFrame;    // 抽奖界面的目标尺寸 为了做动画效果
    int _selectdCardIndex;
    
    NSArray *_randomValueArr;
    BOOL _isDrawing;  // 是否再抽奖请求服务器数据中

}

@property (nonatomic, strong) UIView *backImageView;// 用于灰色半透明
@property (nonatomic, strong) UIButton *backCard;

@property (nonatomic, strong) UIView *backCardView;
@property (nonatomic, strong) UIButton *myRedPacketButton;

@end

@implementation TakeRedPacketView

- (id)initWithView:(CGRect)frame
{
    if (self = [super init]){
        self.backgroundColor = UIColorFromRGB(0xfb6362);
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        _randomValueArr = @[@"20",@"40",@"50",@"60",@"80"];
        _isDrawing = NO;
        
        _tempFrame.origin.x = (frame.size.width - thRedViewWidth)/2;
        _tempFrame.origin.y = 65;
        _tempFrame.size.width = thRedViewWidth;
        _tempFrame.size.height = theRedViewHeight;
        
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(_tempFrame.size.width/2 - 150.0, _tempFrame.size.height/2 - 200.0, 300.0, 400.0)];
        backView.image = [UIImage imageNamed:@"drawaredenvelope_body_background_n@2x.png"];
        [self addSubview:backView];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.backgroundColor = [UIColor clearColor];
        btnCancel.frame = CGRectMake(_tempFrame.size.width - 33.0, 10.0, 23.0, 23.0);
        [btnCancel setImage:[UIImage imageNamed:@"drawaredenvelope_body_close_n@2x.png"] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnCancel];
        
        _cardsButton = [NSMutableArray array];
        for (int index = 0; index < 3; index++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(13 + index*(7 + 90), (_tempFrame.size.height - 125)/2 , 90, 125);
            [button setBackgroundImage:[UIImage imageNamed:@"drawaredenvelope_body_redenvelopes_n@2x.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"drawaredenvelope_body_redenvelopes_n@2x.png"] forState:UIControlStateDisabled];
            button.tag = 10 +index;
            button.enabled = YES;
            [button addTarget:self action:@selector(takeRedPacket:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            
            [_cardsButton addObject:button];
        }
        
        self.myRedPacketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.myRedPacketButton.backgroundColor = [UIColor clearColor];
        self.myRedPacketButton.frame = CGRectMake((_tempFrame.size.width - 121)/2, (_tempFrame.size.height + 125)/2 + 35, 121, 22);
        [self.myRedPacketButton setBackgroundImage:[UIImage imageNamed: @"仁仁分期APP_ios1136_抽取红包-点击状态_03.png"] forState:UIControlStateNormal];
        self.myRedPacketButton.hidden = YES;
        [self.myRedPacketButton addTarget:self action:@selector(goMyredPacket) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.myRedPacketButton];
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return self;
}

- (void)takeRedPacket:(UIButton *)button
{
    if (_isDrawing == YES) {
        return;
    }else{
        _isDrawing = YES;
        _selectdCardIndex = (int)button.tag;
        [self getRedPacketDetailFromAPI];
    }
}

#pragma  mark - 数据处理
// 抽取红包
- (void)getRedPacketDetailFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSDictionary *parameters = @{@"uid":userId};
    
    [AppUtils showLoadIng:@""];
    [manager GET:[NSString stringWithFormat:@"%@%@", API_BASE, POINTS_DRAW_RED] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleDrawRedPacketData:[jsonData objectForKey:@"data"]];
             self.myRedPacketButton.hidden = NO;
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        _isDrawing = NO;
    }];
}

- (void)handleDrawRedPacketData:(NSDictionary *)data
{
    NSString *red_money = [NSString stringWithFormat:@"%@元",[data objectForKey:@"red_money"]];
    NSString *status_name = [NSString stringWithFormat:@"%@元%@",[data objectForKey:@"red_money"], [data objectForKey:@"status_name"]];
    
    for (UIButton *tempButton in _cardsButton){
        if (tempButton.tag == _selectdCardIndex) {
            UIButton *selectedButton  = [_cardsButton objectAtIndex:tempButton.tag - 10];
            selectedButton.enabled = NO;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:selectedButton cache:NO];
            [UIView commitAnimations];
            [selectedButton setBackgroundImage:[UIImage imageNamed:@"havedrawaredenvelope_body_money_n@2x.png"] forState:UIControlStateNormal];
            [selectedButton setBackgroundImage:[UIImage imageNamed:@"havedrawaredenvelope_body_money_n@2x.png"] forState:UIControlStateDisabled];
            
            UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, selectedButton.frame.size.width, 28.0f)];
            moneyLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28];
            moneyLabel.textColor = UIColorFromRGB(0xfb6362);
            moneyLabel.textAlignment = NSTextAlignmentCenter;
            moneyLabel.text = red_money;
            [selectedButton addSubview:moneyLabel];
            
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, selectedButton.frame.size.width, 13.0f)];
            infoLabel.font = GENERAL_FONT13;
            infoLabel.textColor = UIColorFromRGB(0xfb6362);
            infoLabel.text = @"恭喜获得";
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.tag = 12;
            [selectedButton addSubview:infoLabel];
            
            UILabel *redPaketTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, infoLabel.frame.origin.y + infoLabel.frame.size.height + 4.0f, selectedButton.frame.size.width, 13.0f)];
            redPaketTypeLabel.font = GENERAL_FONT13;
            redPaketTypeLabel.textColor = UIColorFromRGB(0xfb6362);
            redPaketTypeLabel.textAlignment = NSTextAlignmentCenter;
            redPaketTypeLabel.text = status_name;
            [selectedButton addSubview:redPaketTypeLabel];
        }
    }
    
    [self performSelector:@selector(openOtherCards) withObject:nil afterDelay:0.5];
}

// 摊其他未选中的牌
- (void)openOtherCards
{
    for (UIButton *tempButton in _cardsButton){
        if (tempButton.tag != _selectdCardIndex) {
            UIButton *selectedButton  = [_cardsButton objectAtIndex:tempButton.tag - 10];
            selectedButton.enabled = NO;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:selectedButton cache:NO];
            [UIView commitAnimations];
            [selectedButton setBackgroundImage:[UIImage imageNamed:@"havedrawaredenvelope_body_cry_n@2x.png"] forState:UIControlStateNormal];
            [selectedButton setBackgroundImage:[UIImage imageNamed:@"havedrawaredenvelope_body_cry_n@2x.png"] forState:UIControlStateDisabled];
            
            UILabel *moneyLabel = (UILabel *)[selectedButton viewWithTag:21];
            if (moneyLabel == nil) {
                moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, selectedButton.frame.size.width, 28.0f)];
                moneyLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28];
                moneyLabel.textColor = UIColorFromRGB(0xffd600);
                moneyLabel.textAlignment = NSTextAlignmentCenter;
                moneyLabel.tag = 21;
                [selectedButton addSubview:moneyLabel];
            }
            moneyLabel.text = [NSString stringWithFormat:@"%@元", [self randomString]];
        }
    }
    
    _isDrawing = NO;
}

- (NSString *)randomString
{
    NSString *temp = @"20";
    int r = arc4random()%[_randomValueArr count];
    if (r < _randomValueArr.count) {
        temp = [_randomValueArr objectAtIndex:r];
    }
    
    return temp;
}

- (void)goMyredPacket
{
    NSLog(@"跳转到我的红包主页");
    [self removeFromSuperview];
    if (self.lookMyRedPacketBlock) {
        self.lookMyRedPacketBlock();
    }
}

- (void)show
{
    UIViewController *topVC = [self appRootViewController];
    self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - _tempFrame.size.width) * 0.5, - _tempFrame.size.height - 30, _tempFrame.size.width, _tempFrame.size.height);
    [topVC.view addSubview:self];
}


- (void)dismiss
{
    [self removeFromSuperview];
    if (self.dismissBlock) {
        self.dismissBlock();
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
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
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
    
    if (!self.backImageView) {
        self.backImageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.6f;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    [topVC.view addSubview:self.backImageView];
    self.transform = CGAffineTransformMakeRotation(-M_1_PI / 2);
    [UIView animateWithDuration:0.35f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = _tempFrame;
    } completion:^(BOOL finished) {
        [super willMoveToSuperview:newSuperview];
    }];
}

@end
