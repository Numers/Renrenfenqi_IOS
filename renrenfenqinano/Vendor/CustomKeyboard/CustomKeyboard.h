//
//  CustomKeyboard.h
//  renrenfenqi
//
//  Created by DY on 15/1/14.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CustomKeyboardDelegate <NSObject>

@required
-(void)sendComment:(NSString *)commentStr;

@end

@interface CustomKeyboard : NSObject<UITextViewDelegate>

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)UIView *hiddeView;
@property (nonatomic,strong)UIViewController *parentViewController;
@property (nonatomic,strong)UIView *secondaryBackView;
@property (nonatomic,strong)UIButton *sendBtn;
@property (nonatomic) BOOL isTop;//用来判断评论按钮的位置

@property (nonatomic,assign) id<CustomKeyboardDelegate>delegate;

+(CustomKeyboard *)customKeyboard;
-(void)textViewShowView:(UIViewController *)viewController customKeyboardDelegate:(id)delegate;

@end
