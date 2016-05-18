//
//  ShareView.m
//  renrenfenqi
//
//  Created by DY on 15/1/12.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "ShareView.h"
#import "CommonTools.h"
#import "AppDelegate.h"
#import "ShareManage.h"
#import "CommonVariable.h"

#define ShareButtonSide   65.0f

@implementation ShareView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setMultipleTouchEnabled:YES];
        [self initBackLayer];
        [self creatMainView:frame];
    }
    return self;
}

// 初始化半透明背景
- (void)initBackLayer {
    _opacityLayer = [CALayer layer];
    _opacityLayer.backgroundColor = [UIColor blackColor].CGColor;
    _opacityLayer.frame = CGRectMake(0.0, 0.0,320, 480);
    _opacityLayer.opacity  = 0.5;
    _opacityLayer.transform = CATransform3DScale(CATransform3DMakeTranslation(0.0,0.0,-200),2,2,1);
    [self.layer addSublayer:_opacityLayer];
}

- (void)creatMainView:(CGRect)frame {
    
    float mainViewWidth = frame.size.width;
    float mainViewHeight = 180.0f;
    float x = 0;
    float y = frame.size.height - mainViewHeight;
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(x, y, mainViewWidth, mainViewHeight)];
    _mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview: _mainView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = GENERAL_FONT18;
    titleLabel.text = @"分享到";
    titleLabel.textColor = UIColorFromRGB(0x737373);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize size = [titleLabel.text sizeWithAttributes:@{NSFontAttributeName:titleLabel.font}];
    titleLabel.frame = CGRectMake(0.5*(_mainView.frame.size.width - size.width), 10.0f, size.width, size.height);
    [_mainView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = UIColorFromRGB(0xe0e0e0);
    line.frame = CGRectMake(0, 40, _mainView.frame.size.width, 0.5f);
    [_mainView addSubview:line];
    
    // 取消按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"photosharing_body_close_n@2x.png"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(_mainView.frame.size.width - 60.0f, 0, 60.0f, 40);
    [closeBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:closeBtn];
    
    // 分享按钮创建  布局：一行2个按钮，按钮之间，按钮与左右边的间距相同原则
    _shareButtonArr =@[@"微信朋友圈",@"微信好友"];
    float distance = (_mainView.frame.size.width - ShareButtonSide*2)/3;
    for (int i = 0; i < _shareButtonArr.count; i++) {
        
        float xoffset = (i + 1)*distance + i*ShareButtonSide;
        float yoffset = line.frame.origin.y + line.frame.size.height + 20;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(xoffset, yoffset, ShareButtonSide, ShareButtonSide);
        button.tag = 1000 +i;
        switch (button.tag) {
            case 1000:
                [button setBackgroundImage:[UIImage imageNamed:@"photosharing_body_weixinquan_n@2x.png"] forState:UIControlStateNormal];
                break;
                
            case 1001:
                [button setBackgroundImage:[UIImage imageNamed:@"photosharing_body_weixin_n@2x.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:button];
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.text = [_shareButtonArr objectAtIndex:i];
        label.font = GENERAL_FONT15;
        label.textColor = UIColorFromRGB(0x737373);
        label.textAlignment = NSTextAlignmentCenter;
        CGSize titleSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        label.frame = CGRectMake(button.center.x - 0.5*titleSize.width, button.frame.origin.y + button.frame.size.height + 10, titleSize.width, titleSize.height);
        [_mainView addSubview:label];
        
    }

}

- (void)showView {
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.window addSubview:self];
}

- (void)dismissView {
    [self removeFromSuperview];
}

// 显示或关闭对话框
- (void)showDialog:(BOOL)bShow {
    if (bShow) {
        [self showDialogAnimation];
    } else {
        [self hideDialogAnimation];
    }
}

// 显示对话框的动画
- (void)showDialogAnimation {
    
    [self showView];
    
    CAAnimation *anim = [self animationMoveY:0.2 from:_MainScreenFrame.size.height+0.5*_mainView.frame.size.height to:_MainScreenFrame.size.height - 0.5*_mainView.frame.size.height];
    [_mainView.layer addAnimation:anim forKey:@"showDialogAnimation"];
    
    anim = [self opacityAnimation:0.2 from:0. to:0.5];
    [_opacityLayer addAnimation:anim forKey:@"opacityAnimation1"];
}

// 关闭对话框的动画
- (void)hideDialogAnimation {
    CAAnimation *anim = [self animationMoveY:0.2 from:_MainScreenFrame.size.height - 0.5*_mainView.frame.size.height to:_MainScreenFrame.size.height + 0.5*_mainView.frame.size.height];
    [anim setDelegate:self];
    [_mainView.layer addAnimation:anim forKey:@"hideDialogAnimation"];
    
    anim = [self opacityAnimation:0.2 from:0.5 to:0];
    [_opacityLayer addAnimation:anim forKey:@"opacityAnimation2"];
    
    // 动画快结束时设置为全透明
    [self performSelector:@selector(delayOpacityToZero:) withObject:_opacityLayer afterDelay:0.13];
}

// 延迟设置透明度为0
- (void)delayOpacityToZero:(id)sender {
    // 防止在窗口消息时闪烁一下
    _mainView.layer.transform = CATransform3DMakeScale(0, 0, 1);
    CALayer *layer = sender;
    [layer setOpacity:0.0];
}

// 动画停止时被调用
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
    [self dismissView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint ptPress;
    for (UITouch *t in touches) {
        // 根据触摸位置创建Line对象
        ptPress = [t locationInView:self];
        break;
    }
    // 点击在对话框
    if ( CGRectContainsPoint(_mainView.frame, ptPress)) {
        
    }else {
        [self onClose:self];
    }
}

#pragma mark 动画效果
// 透明度动画
- (CAAnimation*)opacityAnimation:(float)dur from:(float)from to:(float)to {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = dur;
    animation.fromValue = [NSNumber numberWithFloat:from];
    animation.toValue = [NSNumber numberWithFloat:to];
    animation.removedOnCompletion=YES;
    return animation;
}

// 创建上下移动的动画
- (CAAnimation*)animationMoveY:(float)dur from:(float)from to:(float)to {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = dur;
    animation.fromValue = [NSNumber numberWithFloat:from];
    animation.toValue = [NSNumber numberWithFloat:to];
    animation.removedOnCompletion
    =YES;
    return animation;
}

#pragma 按钮响应

- (void)onClose:(id)sender {
    [self hideDialogAnimation];
}

- (void)shareButtonAction:(UIButton *)sender {
    switch (sender.tag) {
        case 1000:
            NSLog(@"点击微信朋友圈分享");
            [self sendVideoToWeChat:WXSceneTimeline];
            break;
            
        case 1001:
            NSLog(@"点击微信好友分享");
            [self sendVideoToWeChat:WXSceneSession];
            break;
            
        default:
            break;
    }
}

-(void) sendVideoToWeChat:(int)scene
{
    if (self.thumbnail == nil) {
        self.thumbnail = [CommonVariable defaultShareIcon];
    }
    NSString *title = self.titleString;
    if (scene == 1){
        title = [NSString stringWithFormat:@"小伙伴分享了个仁仁分期的活动：%@。快去瞧瞧吧", title];
    }
    NSString *description = [NSString stringWithFormat:@"我刚刚在仁仁分期看到了一个很赞的活动！朋友们快来围观~%@", self.url];
    
    [ShareManage shareVideoToWeixinPlatform:scene themeUrl:self.url thumbnail:self.thumbnail title:title descript:description];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
