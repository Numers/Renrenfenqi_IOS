//
//  CustomKeyboard.m
//  renrenfenqi
//
//  Created by DY on 15/1/14.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CustomKeyboard.h"
#import "CommonTools.h"

@implementation CustomKeyboard

static CustomKeyboard *customKeyboard = nil;

+(CustomKeyboard *)customKeyboard
{
    @synchronized(self)
    {
        if (customKeyboard == nil)
        {
            customKeyboard = [[CustomKeyboard alloc] init];
        }
        return customKeyboard;
    }
}
+(id)allocWithZone:(struct _NSZone *)zone //确保使用者alloc时 返回的对象也是实例本身
{
    @synchronized(self)
    {
        if (customKeyboard == nil)
        {
            customKeyboard = [super allocWithZone:zone];
        }
        return customKeyboard;
    }
}
+(id)copyWithZone:(struct _NSZone *)zone //确保使用者copy时 返回的对象也是实例本身
{
    return customKeyboard;
}

-(void)textViewShowView:(UIViewController *)viewController customKeyboardDelegate:(id)delegate
{
    self.parentViewController =viewController;
    self.delegate =delegate;
    self.isTop = NO;//初始化的时候设为NO
    
    self.backView =[[UIView alloc]initWithFrame:CGRectMake(0, _MainScreenFrame.size.height -50, _MainScreenFrame.size.width, 50)];
    NSLog(@"%p",self.backView);
    self.backView.backgroundColor =UIColorFromRGB(0xf7f7f7);
    [self.parentViewController.view addSubview:self.backView];
    
    self.sendBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendBtn setImage:[UIImage imageNamed:@"graphicdetails_body_send_n@2x.png"] forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(touchSendBtn) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.frame =CGRectMake(self.backView.frame.size.width - 65, 10, 50, 30);
    [self.backView addSubview:self.sendBtn];
    
    // 预留防止修改要边框的感觉
    self.secondaryBackView =[[UIView alloc]initWithFrame:CGRectMake(15, 10, _MainScreenFrame.size.width - 40 - self.sendBtn.frame.size.width, 30)];
    self.secondaryBackView.backgroundColor =UIColorFromRGB(0xe6e6e6);
    [self.backView addSubview:self.secondaryBackView];
    
    self.textView =[[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.secondaryBackView.frame.size.width, self.secondaryBackView.frame.size.height)];
    self.textView.backgroundColor =UIColorFromRGB(0xe6e6e6);
    self.textView.delegate = self;
    self.textView.font = GENERAL_FONT14;
    self.textView.textColor = UIColorFromRGB(0x929292);
    self.textView.text = @"说点什么吧...";
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.secondaryBackView addSubview:self.textView];
    
//    UIImageView *talkImg =[[UIImageView alloc]initWithFrame:CGRectMake(250, 16, 18, 18)];
//    talkImg.image =[UIImage imageNamed:@"icon_0040_Shape-36.png"];
//    [self.backView addSubview:talkImg];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textView resignFirstResponder];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textView.text = nil;
    self.textView.textColor = [UIColor blackColor];
    return YES;
}

-(void)touchSendBtn //评论按钮
{
    
    if (self.isTop ==NO)
    {
        [self.textView becomeFirstResponder];
    }
    else
    {
        if (self.textView.text.length==0)
        {
            [AppUtils showLoadInfo:@"评论不能为空"];
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(sendComment:)]) {
                [self.delegate sendComment:self.textView.text];
            }
            
            [self.textView resignFirstResponder];
        }
    }
    
}
-(void)hideView //点击屏幕其他地方 键盘消失
{
    NSLog(@"屏幕消失");
    [self.textView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)notification //键盘出现
{
    self.isTop =YES;
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"%f-%f",_keyboardRect.origin.y,_keyboardRect.size.height);
    
    if (!self.hiddeView)
    {
        self.hiddeView =[[UIView alloc]initWithFrame:CGRectMake(0, 0,_MainScreenFrame.size.width,_MainScreenFrame.size.height)];
        self.hiddeView.backgroundColor =[UIColor blackColor];
        self.hiddeView.alpha =0.0f;
        [self.parentViewController.view addSubview:self.hiddeView];
        
        UIButton *hideBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        hideBtn.backgroundColor =[UIColor clearColor];
        hideBtn.frame = self.hiddeView.frame;
        [hideBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [self.hiddeView addSubview:hideBtn];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.hiddeView.alpha =0.4f;
        self.backView.frame =CGRectMake(0, _MainScreenFrame.size.height-_keyboardRect.size.height-50, _MainScreenFrame.size.width, 50);
        [self.parentViewController.view bringSubviewToFront:self.backView];
    } completion:^(BOOL finished) {
        
    }];
}
- (void)keyboardWillHide:(NSNotification*)notification //键盘下落
{
    self.isTop =NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.frame=CGRectMake(0, _MainScreenFrame.size.height-50, _MainScreenFrame.size.width, 50);
        self.hiddeView.alpha =0.0f;
        self.secondaryBackView.frame =CGRectMake(15, 10, _MainScreenFrame.size.width - 40 - self.sendBtn.frame.size.width, 30);
    } completion:^(BOOL finished) {
        [self.hiddeView removeFromSuperview];
        self.hiddeView =nil;
        self.textView.text =@"说点什么吧..."; //键盘消失时，恢复TextView内容
        self.textView.textColor = UIColorFromRGB(0x929292);
    }];
}
- (void)textDidChanged:(NSNotification *)notif //监听文字改变 换行时要更改输入框的位置
{
    CGSize contentSize = self.textView.contentSize;
    
    if (contentSize.height > 130){
        return;
    }
    CGFloat minus = 3;
    CGRect selfFrame = self.backView.frame;
    CGFloat selfHeight = self.textView.superview.frame.origin.y * 2 + contentSize.height - minus + 2 * 2;
    CGFloat selfOriginY = selfFrame.origin.y - (selfHeight - selfFrame.size.height);
    selfFrame.origin.y = selfOriginY;
    selfFrame.size.height = selfHeight;
    self.backView.frame = selfFrame;
    self.secondaryBackView.frame =CGRectMake(15, 10, _MainScreenFrame.size.width - 40 - self.sendBtn.frame.size.width, selfHeight-20);
}

-(void)dealloc //移除通知
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

@end
