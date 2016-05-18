//
//  UnusualView.m
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "UnusualView.h"
#import "AppUtils.h"

#define picSize CGSizeMake(135.0f, 140.0f)

@interface UnusualView ()

@property (strong, nonatomic) UIImageView *picImageView;
@property (strong, nonatomic) UILabel     *messageLabel;

@end

@implementation UnusualView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf8f8f8);
        [self setMultipleTouchEnabled:YES];
        [self initUI:frame];
    }
    return self;
}

- (void)initUI:(CGRect)frame {
    CGRect tempFrame = CGRectZero;
    tempFrame.origin.x = self.frame.size.width/2 - picSize.width/2;
    tempFrame.origin.y = self.frame.size.height/2 - picSize.height/2 - 30.0f;//30.0f为 向上提预留文字高度
    tempFrame.size = picSize;
    
    _picImageView = [[UIImageView alloc] initWithFrame:tempFrame];
    [self addSubview:_picImageView];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.frame = CGRectMake(15, _picImageView.frame.origin.y + _picImageView.frame.size.height + 15, _MainScreen_Width - 30.0f, 15.0f);
    _messageLabel.font = [UIFont systemFontOfSize:13];
    _messageLabel.textColor = [UIColor grayColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_messageLabel];
}

- (void)refreshView {
    _picImageView.image = _picImage;
    _messageLabel.text = [AppUtils filterNull:_messageStr];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
