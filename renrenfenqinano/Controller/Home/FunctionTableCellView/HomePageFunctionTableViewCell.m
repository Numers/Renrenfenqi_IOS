//
//  HomePageFunctionTableViewCell.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/21.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "HomePageFunctionTableViewCell.h"

@implementation HomePageFunctionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)clickLeftBtn
{
    if ([self.delegate respondsToSelector:@selector(clickLeftButton)]) {
        [self.delegate clickLeftButton];
    }
}

-(void)clickMiddleBtn
{
    if ([self.delegate respondsToSelector:@selector(clickMiddleButton)]) {
        [self.delegate clickMiddleButton];
    }
}

-(void)clickRightBtn
{
    if ([self.delegate respondsToSelector:@selector(clickRightButton)]) {
        [self.delegate clickRightButton];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setFrame:CGRectMake(-0.5, 0.5, self.frame.size.width / 3.0f, (140.0f * self.frame.size.width) / (3.0f * 213.0f))];
    [leftButton setImage:[UIImage imageNamed:@"Homepage_GoodCategoryBtn"] forState:UIControlStateNormal];
    [self addSubview:leftButton];
    
    UIView *lineSeperate1 = [[UIView alloc] initWithFrame:CGRectMake(leftButton.frame.origin.x + leftButton.frame.size.width, 0.5, 0.5, leftButton.frame.size.height)];
    [lineSeperate1 setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5]];
    [self addSubview:lineSeperate1];
    
    middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleButton addTarget:self action:@selector(clickMiddleBtn) forControlEvents:UIControlEventTouchUpInside];
    [middleButton setFrame:CGRectMake(leftButton.frame.origin.x + leftButton.frame.size.width + 0.5, 0.5, self.frame.size.width / 3.0f, (140.0f * self.frame.size.width) / (3.0f * 213.0f))];
    [middleButton setImage:[UIImage imageNamed:@"Homepage_CreditAccountBtn"] forState:UIControlStateNormal];
    [self addSubview:middleButton];
    
    UIView *lineSeperate2 = [[UIView alloc] initWithFrame:CGRectMake(middleButton.frame.origin.x + middleButton.frame.size.width, 0.5, 0.5, leftButton.frame.size.height)];
    [lineSeperate2 setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5]];
    [self addSubview:lineSeperate2];
    
    rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setFrame:CGRectMake(middleButton.frame.origin.x + middleButton.frame.size.width + 0.5, 0.5, self.frame.size.width / 3.0f, (140.0f * self.frame.size.width) / (3.0f * 213.0f))];
    [rightButton setImage:[UIImage imageNamed:@"Homepage_PartJobBtn"] forState:UIControlStateNormal];
    [self addSubview:rightButton];
}
@end
