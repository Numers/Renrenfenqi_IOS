//
//  WishTableViewCell.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "WishTableViewCell.h"
#import "AppUtils.h"
#import "AppDelegate.h"

@implementation WishTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.goodsNameTextField.delegate = self;
    self.goodsNameTextField.returnKeyType = UIReturnKeyNext;
    self.goodsNameTextField.keyboardType = UIKeyboardTypeDefault;
    
    self.phoneTextField.delegate = self;
    self.phoneTextField.returnKeyType = UIReturnKeyDone;
    self.phoneTextField.keyboardType = UIKeyboardTypeDefault;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 按钮响应

- (IBAction)commitWish:(UIButton *)sender {
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        if ([self.goodsNameTextField.text isEqualToString:@""]) {
            [AppUtils showLoadInfo:@"心愿单内容不能为空哦～"];
        }else if ([self getToInt:self.goodsNameTextField.text] > 80){
            [AppUtils showLoadInfo:@"心愿单内容不能超过80个字符"];
        }else if (![AppUtils isMobileNumber:self.phoneTextField.text]) {
            [AppUtils showLoadInfo:@"错误的手机号码，请重新输入"];
        }else{
            NSLog(@"点击提交心愿单");
            if ([self.delegate respondsToSelector:@selector(touchCommitBtn:goods:userId:)]) {
                [self.delegate touchCommitBtn:self.phoneTextField.text goods:self.goodsNameTextField.text userId:userId];
                
                self.goodsNameTextField.text = @"";
                self.phoneTextField.text = @"";
            }
        }

    }else{
//        [AppUtils showLoadInfo:@"请先登录账号"];
//        UITabBarController *tbc = (UITabBarController*)[app.window rootViewController];
//        if(![tbc isKindOfClass: [UITabBarController class]]){
//            return;
//        }
//        [tbc setSelectedIndex:3];
        if ([self.delegate respondsToSelector:@selector(goLoginFromWish)]) {
            [self.delegate goLoginFromWish];
        }
    }
}

-(int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [strtemp dataUsingEncoding:enc];
    
    return (int)data.length;
}

#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.goodsNameTextField){
        [self.goodsNameTextField resignFirstResponder];
        [self.phoneTextField becomeFirstResponder];
    }else if (textField == self.phoneTextField){
        [self.phoneTextField resignFirstResponder];
    }
    
    return YES;
}

@end
