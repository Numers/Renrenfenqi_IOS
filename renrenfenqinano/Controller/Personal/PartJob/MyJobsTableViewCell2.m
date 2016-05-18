//
//  MyJobsTableViewCell2.m
//  renrenfenqi
//
//  Created by DY on 15/2/8.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "MyJobsTableViewCell2.h"
#import "CommonTools.h"
#import "CommonVariable.h"

@interface MyJobsTableViewCell2 ()
{
    CGSize _mainScreenSize;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *areaLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *feedbackLabel;
@property (strong, nonatomic) UIView  *feedBackView; // 反馈信息的灰色

@end

@implementation MyJobsTableViewCell2

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViewData];
        [self initUI];
    }
    return self;
}

- (void)initViewData {
    _mainScreenSize = _MainScreenFrame.size;
}

// 创建cellUI
- (void)initUI {
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = GENERAL_FONT14;
    self.statusLabel.textColor = [CommonVariable redFontColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.statusLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = GENERAL_FONT14;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    
    self.areaLabel = [[UILabel alloc] init];
    self.areaLabel.backgroundColor = [UIColor clearColor];
    self.areaLabel.font = GENERAL_FONT12;
    self.areaLabel.textColor = [CommonVariable grayFontColor];
    self.areaLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.areaLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = GENERAL_FONT12;
    self.dateLabel.textColor = [CommonVariable grayFontColor];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.dateLabel];
    
    self.feedBackView = [[UIView alloc] init];
    self.feedBackView.backgroundColor = [CommonVariable grayBackgroundColor];
    [self addSubview:self.feedBackView];
    
    self.feedbackLabel = [[UILabel alloc] init];
    self.feedbackLabel.backgroundColor = [UIColor clearColor];
    self.feedbackLabel.font = GENERAL_FONT12;
    self.feedbackLabel.textColor = [CommonVariable grayFontColor];
    self.feedbackLabel.textAlignment = NSTextAlignmentLeft;
    self.feedbackLabel.numberOfLines = 0;
    [self.feedBackView addSubview:self.feedbackLabel];
}

- (void)myJobsData:(NSDictionary *)dic {
    self.statusLabel.text = [AppUtils filterNull:[dic objectForKey:@"is_state"]];
    if ([self.statusLabel.text isEqual:@"审核成功"]) {
        self.statusLabel.textColor = [CommonVariable greenFontColor];
    }else{
        self.statusLabel.textColor = [CommonVariable redFontColor];
    }
    CGSize textSize = [self.statusLabel.text sizeWithAttributes:@{NSFontAttributeName:self.statusLabel.font}];
    self.statusLabel.frame = CGRectMake(_mainScreenSize.width - (textSize.width + 30.0f), 16.0f, textSize.width + 30.0f, 14.0f);
    
    self.titleLabel.text = [AppUtils filterNull:[dic objectForKey:@"title"]];
    self.titleLabel.frame = CGRectMake(15.0f, 16.0f, _mainScreenSize.width - (15.0f + self.statusLabel.frame.size.width), 14.0f);
    
    self.areaLabel.text = [AppUtils filterNull:[dic objectForKey:@"region"]];
    textSize = [self.areaLabel.text sizeWithAttributes:@{NSFontAttributeName:self.areaLabel.font}];
    self.areaLabel.frame = CGRectMake(15.0f, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 9.0f,textSize.width, 12.0f);
    
    self.dateLabel.text = [AppUtils filterNull:[[dic objectForKey:@"apply_time"] substringToIndex:10]];
    textSize = [self.dateLabel.text sizeWithAttributes:@{NSFontAttributeName:self.dateLabel.font}];
    self.dateLabel.frame = CGRectMake(_mainScreenSize.width- (15.0f + textSize.width), self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 9.0f, textSize.width, 12.0f);
    
    if ([AppUtils isNullStr:[dic objectForKey:@"state_info"]]) {
        self.feedbackLabel.hidden = YES;
        self.feedBackView.hidden = YES;
        return;
    }else{
        self.feedbackLabel.hidden = NO;
        self.feedBackView.hidden = NO;
    }
    self.feedbackLabel.text = [NSString stringWithFormat:@"仁仁君反馈：%@", [AppUtils filterNull:[dic objectForKey:@"state_info"]]];
    CGSize maxContentSize = CGSizeMake(_mainScreenSize.width - 30.0f, 800.0f);
    CGSize feedbackSize = [self.feedbackLabel.text boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.feedbackLabel.font} context:nil].size;
    self.feedbackLabel.frame = CGRectMake(5.0f, 10.0f, feedbackSize.width, feedbackSize.height);
    self.feedBackView.frame = CGRectMake(10.0f, self.areaLabel.frame.origin.y + self.areaLabel.frame.size.height + 10.0f, _mainScreenSize.width - 20.0f, feedbackSize.height + 20.0f);
}

@end
