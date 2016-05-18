//
//  OnlyPartTimeTableViewCell.m
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "OnlyPartTimeTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CommonVariable.h"
#import "AppUtils.h"

@interface OnlyPartTimeTableViewCell()
{
    float _jobIconImageSide;     // 兼职类型图标边长
    float _capcityIconImageSide; // 技能类型图标边长
    float _backViewHeight;       // 白色背景图片高度
    float _capcityCount;         // 能力值个数
    
    CGPoint _grayLinePoint;      // 分割兼职图片和技能图标的灰线
    CGSize _mainScreenSize;      // 当前手机的屏幕尺寸
    CGSize _capcitySize;         // 能力值背景区域大小
    
    NSMutableArray *_capcityImageViewArr; // 技能图标容器
    NSMutableArray *_capcityLabelArr;     // 技能文本容器
}

@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *jobImageView; // 工种图片

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *payLabel;

@property (strong, nonatomic) UIView *grayLine;

@end

@implementation OnlyPartTimeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
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
    _jobIconImageSide = 65.0f;
    _capcityIconImageSide = 15.0f;
    _backViewHeight = 130.0f;
    
    _grayLinePoint = CGPointMake(15.0f, 90.0f);
    _mainScreenSize = _MainScreenFrame.size;
    _capcitySize = CGSizeMake(_mainScreenSize.width, 40.0f);
    _capcityCount = 3;
    
    _capcityImageViewArr = [NSMutableArray array];
    _capcityLabelArr = [NSMutableArray array];
}

// 创建cellUI
- (void)initUI {
    // 白色背景
    self.backView = [[UIView alloc] init];
    self.backView.frame = CGRectMake(0, 0, _mainScreenSize.width, _backViewHeight);
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
    
    // 兼职类型图标和技能图标灰色分割线
    self.grayLine = [[UIView alloc] init];
    self.grayLine.frame = CGRectMake(_grayLinePoint.x, _grayLinePoint.y, _mainScreenSize.width - 15.0f, 0.5f);
    self.grayLine.backgroundColor = [CommonVariable grayLineColor];
    [self.backView addSubview:self.grayLine];
    
    // 兼职类型图标
    self.jobImageView = [[UIImageView alloc] init];
    self.jobImageView.frame = CGRectMake(15.0f, 12.5f, _jobIconImageSide, _jobIconImageSide);
    self.jobImageView.layer.cornerRadius = 0.5*_jobIconImageSide;
    self.jobImageView.layer.masksToBounds = YES;
    [self.backView addSubview:self.jobImageView];
    
    // 兼职标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = GENERAL_FONT13;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    [self.backView addSubview:self.titleLabel];
    
    // 待遇
    self.payLabel = [[UILabel alloc] init];
    self.payLabel.textAlignment = NSTextAlignmentLeft;
    self.payLabel.font = GENERAL_FONT13;
    self.payLabel.textColor = [CommonVariable grayFontColor];
    [self.backView addSubview:self.payLabel];
    
    // 技能图标和文本
    if (_capcityImageViewArr.count > 0) {
        [_capcityImageViewArr removeAllObjects];
    }
    if (_capcityLabelArr.count > 0) {
        [_capcityLabelArr removeAllObjects];
    }
    
    for (int index = 0; index < _capcityCount; index ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.backView addSubview:imageView];
        [_capcityImageViewArr addObject:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = GENERAL_FONT13;
        label.textColor = [CommonVariable grayFontColor];
        [self.backView addSubview:label];
        [_capcityLabelArr addObject:label];
    }
    
    // 底部灰色线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.frame = CGRectMake(0, self.backView.frame.size.height - 0.5f, self.backView.frame.size.width, 0.5f);
    bottomLine.backgroundColor = [CommonVariable grayLineColor];
    [self.backView addSubview:bottomLine];
}

- (void)jobsData:(NSDictionary *)dic {
    // 头像数据
    NSString *imagePath = [[dic objectForKey:@"ice_url"] stringByAppendingString:[dic objectForKey:@"ice"]];
    [self.jobImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"myparttime_body_job_faile_n.png"]];
    
    // 标题和待遇
    NSString *titleText =[NSString stringWithFormat:@"%@", [dic objectForKey:@"title"]];
    NSString *payText = [NSString stringWithFormat:@"待遇：%@", [dic objectForKey:@"type_wage"]];
    
    CGSize payTextSize = [payText sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT13}];
    CGSize maxContentSize = CGSizeMake(self.backView.frame.size.width - (self.jobImageView.frame.origin.x + self.jobImageView.frame.size.width + 39.0f) ,2*payTextSize.height + 4.0f);
    CGSize titleSize = [titleText boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:GENERAL_FONT13} context:nil].size;
    
    self.titleLabel.frame = CGRectMake(self.jobImageView.frame.origin.x + self.jobImageView.frame.size.width + 9.0f, 0.5*(90.0f - titleSize.height - payTextSize.height - 5.0f), titleSize.width, titleSize.height);
    self.titleLabel.text = [AppUtils filterNull:titleText];
    
    self.payLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0f, payTextSize.width, payTextSize.height);
    NSRange range = [payText rangeOfString:@"待遇："];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:payText];
    [str addAttribute:NSForegroundColorAttributeName value:[CommonVariable redFontColor] range:NSMakeRange(range.length,payText.length - range.length)];
    self.payLabel.attributedText = str;
    
    NSArray *capacityArr = [[dic objectForKey:@"latitude_param"] copy];
    float tempWidth = _capcitySize.width/_capcityCount;
    NSString *capacityType = nil;
    NSString *capacityValue = nil;
    for (int index = 0; index < capacityArr.count; index ++) {
        if (index > 2) {
            return;
        }
        capacityType = [AppUtils filterNull:[NSString stringWithFormat:@"%@", [[capacityArr objectAtIndex:index] objectForKey:@"name"]]];
        capacityValue = [AppUtils filterNull:[NSString stringWithFormat:@"%@", [[capacityArr objectAtIndex:index] objectForKey:@"num"]]];
        CGSize textSize = [[NSString stringWithFormat:@"%@+%@", capacityType, capacityValue] sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT13}];
        float totalWidth = textSize.width + _capcityIconImageSide + 8.0f;
        float xOffset = (tempWidth - totalWidth)/2 + index*tempWidth;
        
        UIImageView *imageView = [_capcityImageViewArr objectAtIndex:index];
        imageView.image = [self capacityIcon:capacityType];
        imageView.frame = CGRectMake(xOffset, self.grayLine.frame.origin.y + self.grayLine.frame.size.height + 12.5f, _capcityIconImageSide, _capcityIconImageSide);
        
        UILabel *label = [_capcityLabelArr objectAtIndex:index];
        label.text = [NSString stringWithFormat:@"%@+%@", capacityType, capacityValue];
        label.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, imageView.frame.origin.y, textSize.width, textSize.height);
    }
}

- (UIImage *)capacityIcon:(NSString *)capacityIconName {
    
    UIImage *tempImage = [UIImage imageNamed:@"justwork_body_default_n@2x.png"];
    if ([capacityIconName isEqual:@"执行力"]) {
        tempImage = [UIImage imageNamed:@"justwork_body_carriedout_n@2x.png"];
    }else if ([capacityIconName isEqual:@"抗压性"]) {
        tempImage = [UIImage imageNamed:@"justwork_body_antistress_n@2x.png"];
    }else if ([capacityIconName isEqual:@"沟通力"]) {
        tempImage = [UIImage imageNamed:@"justwork_body_communication_n@2x.png"];
    }else if ([capacityIconName isEqual:@"学习力"]) {
        tempImage = [UIImage imageNamed:@"justwork_body_study_n@2x.png"];
    }else if ([capacityIconName isEqual:@"诚信值"]) {
        tempImage = [UIImage imageNamed:@"justwork_body_honesty_n@2x.png"];
    }
    
    return tempImage;
}

@end
