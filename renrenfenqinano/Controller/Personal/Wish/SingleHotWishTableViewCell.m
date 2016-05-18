//
//  SingleHotWishTableViewCell.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "SingleHotWishTableViewCell.h"
#import "AppDelegate.h"
#import "AppUtils.h"

@implementation SingleHotWishTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.rankingLabel.text = @"";
    self.goodsLabel.text = @"";
    self.praiseCountLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hotWishData:(NSDictionary *)data
{
    self.praiseBtn.tag = [[data objectForKey:@"wish_id"] intValue];
    self.rankingLabel.text = self.rankString;
    self.goodsLabel.text = [data objectForKey:@"goods_name"];
    self.praiseCountLabel.text = [data objectForKey:@"laud"];
    
    if ([[data objectForKey:@"status"] boolValue]) {
        [self.praiseBtn setImage:[UIImage imageNamed:@"mywishlisthome_body_point_h@2x.png"] forState:UIControlStateNormal];
    }else{
        [self.praiseBtn setImage:[UIImage imageNamed:@"mywishlisthome_body_point_n@2x.png"] forState:UIControlStateNormal];
    }
}

#pragma mark 按钮响应

- (IBAction)praise:(UIButton *)sender {
    NSLog(@"点击点赞buttontag: %d", (int)sender.tag);
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        if ([self.delegate respondsToSelector:@selector(touchPraiseBtn:userId:)]) {
            [self.delegate touchPraiseBtn:(int)sender.tag userId:userId];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(goLoginFromHotWish)]) {
            [self.delegate goLoginFromHotWish];
        }
//        [AppUtils showLoadInfo:@"请先登录账号"];
//        UITabBarController *tbc = (UITabBarController*)[app.window rootViewController];
//        if(![tbc isKindOfClass: [UITabBarController class]]){
//            return;
//        }
//        [tbc setSelectedIndex:3];
    }
    
    
}

@end
