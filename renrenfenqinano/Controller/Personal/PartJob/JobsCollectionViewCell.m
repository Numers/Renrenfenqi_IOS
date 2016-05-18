//
//  JobsCollectionViewCell.m
//  renrenfenqi
//
//  Created by DY on 15/2/25.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "JobsCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppUtils.h"
#import "CommonVariable.h"

@interface JobsCollectionViewCell()
{
    NSMutableArray *_capacityLabelArr;    // 能力值label容器
    NSMutableArray *_capacityRectangleArr;// 能力值 方块图形容器
    NSMutableArray *_capacityValueArr;    // 能力值
    
    float _capacityViewHeight;
    float _jobViewHeight;
    float _jobImageSide;
    int   _rectangleRowCount; //
    int   _rectangleCount;
    
//    CGSize _rectangleSize;
}

@property (strong, nonatomic) UIView      *capacityView;
@property (strong, nonatomic) UIView      *jobView;
@property (strong, nonatomic) UIImageView *jobImageView;

@property (strong, nonatomic) UILabel *payLabel;
@property (strong, nonatomic) UILabel *emptyLabel;

@end

@implementation JobsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewData];
        [self initUI];
    }
    return self;
}

- (void)initViewData {
    _capacityLabelArr = [NSMutableArray array];
    _capacityRectangleArr = [NSMutableArray array];
    _capacityValueArr = [NSMutableArray array];
    
    float scale = _MainScreen_Width / Iphone5Width;
    _capacityViewHeight = ceilf(scale*90.0f);
    _jobViewHeight = self.frame.size.height - _capacityViewHeight;
    _jobImageSide = ceilf(scale*94.0f);
    _rectangleRowCount = 3;
    _rectangleCount = 5;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = UIColorFromRGB(0xeaeaea).CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    // 兼职工种卡牌兼职图片和待遇
    self.jobView = [[UIView alloc] init];
    self.jobView.frame = CGRectMake(0, 0, self.frame.size.width, _jobViewHeight);
    [self addSubview:self.jobView];
    
    float font18Height = [@"待遇" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT18}].height;
    float xoffset = 0.5*(self.jobView.frame.size.width - _jobImageSide);
    float yoffset = 0.5*(_jobViewHeight - (_jobImageSide + font18Height + 10.0f));
    self.jobImageView = [[UIImageView alloc] init];
    self.jobImageView.frame = CGRectMake(xoffset, yoffset, _jobImageSide, _jobImageSide);
    self.jobImageView.layer.cornerRadius = self.jobImageView.frame.size.width/2;
    self.jobImageView.layer.masksToBounds = YES;
    [self.jobView addSubview:self.jobImageView];
    
    self.payLabel = [[UILabel alloc] init];
    self.payLabel.font = GENERAL_FONT18;
    self.payLabel.textColor = [UIColor whiteColor];
    self.payLabel.textAlignment = NSTextAlignmentCenter;
    self.payLabel.frame = CGRectMake(5.0f, self.jobImageView.frame.origin.y + self.jobImageView.frame.size.height + 10.0f, self.jobView.frame.size.width - 10.0f, font18Height);
    [self.jobView addSubview:self.payLabel];
    
    // 兼职工种卡牌兼职工种能力值
    self.capacityView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _capacityViewHeight, self.frame.size.width, _capacityViewHeight)];
    self.capacityView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.capacityView];
    
    if (_capacityLabelArr.count > 0) {
        [_capacityLabelArr removeAllObjects];
    }
    if (_capacityValueArr.count > 0) {
        [_capacityValueArr removeAllObjects];
    }
    
    /*
     1.确定能力值的名字和值的UILabel的x坐标
     2.整体宽度-能力值label的宽度和偏移 -能力名称label的宽度和偏移 - 矩形之间的间距和
     3.2中得到的宽度除以矩形的个数
     */
    CGSize textSize = [@"沟通力" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT14}];
    CGSize textValueSize = [@"+3" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT14}];
    float textXoffset = 24.0f;
    float textValueXoffset = self.frame.size.width - textValueSize.width - textXoffset;
    CGSize rectangleSize = CGSizeMake(15.0f, 7.0f);
    if (_rectangleCount > 0) {
        rectangleSize.width = ceilf((self.frame.size.width - (textXoffset + textSize.width) - (textValueSize.width + textXoffset) - 2*10.0f -(_rectangleCount - 1)*1.0f)/_rectangleCount);
    }
    for (int index = 0; index < _rectangleRowCount; index++) {
        float yoffset = 0.5*(self.capacityView.frame.size.height - 3*textSize.height - 2*7.0f) + index*(textSize.height + 7.0f);
        UILabel *label = [[UILabel alloc] init];
        label.font = GENERAL_FONT14;
        label.textColor = [CommonVariable grayFontColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.frame = CGRectMake(textXoffset, yoffset, textSize.width, textSize.height);
        [self.capacityView addSubview:label];
        [_capacityLabelArr addObject:label];
        
        for (int rectangleIndex = 0; rectangleIndex < _rectangleCount; rectangleIndex++) {
            float xoffset = label.frame.origin.x + label.frame.size.width + 10.0f + rectangleIndex*(rectangleSize.width + 1.0f);
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = UIColorFromRGB(0xf9f0f1);
            view.tag = 10*index + rectangleIndex + 1;
            view.frame = CGRectMake(xoffset, yoffset + 0.5*(textSize.height - rectangleSize.height) + 1.0f, rectangleSize.width, rectangleSize.height);
            [self.capacityView addSubview:view];
            [_capacityRectangleArr addObject:view];
            
            if (rectangleIndex == 4) {
                UILabel *valueLabel = [[UILabel alloc] init];
                valueLabel.font = GENERAL_FONT14;
                valueLabel.textColor = [CommonVariable grayFontColor];
                valueLabel.textAlignment = NSTextAlignmentLeft;
                valueLabel.frame = CGRectMake(textValueXoffset, label.frame.origin.y, textValueSize.width, textValueSize.height);
                [self.capacityView addSubview:valueLabel];
                [_capacityValueArr addObject:valueLabel];
            }
        }
    }
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.backgroundColor = [UIColor clearColor];
    self.emptyLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.emptyLabel.textColor = [CommonVariable grayFontColor];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.frame = self.capacityView.frame;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.emptyLabel.hidden = YES;
    [self addSubview:self.emptyLabel];
}

- (void)parttimeJobsData:(NSDictionary *)dic specialCard:(BOOL)isSpecialCard {
    if (isSpecialCard) {
        self.capacityView.hidden = YES;
        self.emptyLabel.hidden = NO;
        self.jobView.backgroundColor = UIColorFromRGB(0xdcdcdc);
        self.jobImageView.image = [UIImage imageNamed:@"myparttime_body_nothing_n@2x.png"];
        self.payLabel.text = @"没有中意的职位？";
        self.emptyLabel.text = @"客服妹子\n会帮你量身定制";
    }else{
        self.capacityView.hidden = NO;
        self.emptyLabel.hidden = YES;
        NSString *jobName = [AppUtils filterNull:[dic objectForKey:@"cname"]];
        self.jobView.backgroundColor = [self jobCardColorByJobName:jobName];
        
        NSString *imagePath = [[AppUtils filterNull:[dic objectForKey:@"ice_url"]] stringByAppendingString:[AppUtils filterNull:[dic objectForKey:@"ice"]]];
        [self.jobImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]  placeholderImage:[UIImage imageNamed:@"myparttime_body_job_faile_n.png"]];
        
        NSString *payText = [NSString stringWithFormat:@"待遇：%@", [dic objectForKey:@"position_wage"]];
        self.payLabel.text = [AppUtils filterNull:payText];
        
        NSArray *tempArr = [[dic objectForKey:@"latitude_param"] mutableCopy];
        for (int index = 0; index < _capacityLabelArr.count; index ++) {
            if (![[_capacityLabelArr objectAtIndex:index] isKindOfClass:[UILabel class]]) {
                break;
            }
            UILabel *label = [_capacityLabelArr objectAtIndex:index];
            if (index < tempArr.count) {
                label.text = [AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"name"]];
            }
        }
        
        for (int index = 0; index < _capacityValueArr.count; index ++) {
            if (![[_capacityValueArr objectAtIndex:index] isKindOfClass:[UILabel class]]) {
                break;
            }
            UILabel *label = [_capacityValueArr objectAtIndex:index];
            if (index < tempArr.count) {
                label.text = [NSString stringWithFormat:@"+%@", [AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"num"]]];
                int value = [[[tempArr objectAtIndex:index] objectForKey:@"num"] intValue];
                UIColor *capacityColor = [self rectangleColorByCapacityName:[AppUtils filterNull:[[tempArr objectAtIndex:index] objectForKey:@"name"]]];
                for (int i = 0; i < 5; i++) {
                    if (5*index + i > _capacityRectangleArr.count) {
                        break;
                    }
                    
                    if (![[_capacityRectangleArr objectAtIndex:index] isKindOfClass:[UIView class]]) {
                        break;
                    }
                    
                    UIView *colorView = [_capacityRectangleArr objectAtIndex:5*index + i];
                    if (i < value) {
                        colorView.backgroundColor = capacityColor;
                    }else{
                        colorView.backgroundColor = UIColorFromRGB(0xf9f0f1);
                    }
                }
            }
        }

    }
}

- (UIColor *)rectangleColorByCapacityName:(NSString *)capacityName {
    UIColor *tempColor = UIColorFromRGB(0xf9f0f1);
    if ([capacityName isEqual:@"经验值"]) {
        tempColor = UIColorFromRGB(0xafdff3);
    }else if ([capacityName isEqual:@"执行力"]) {
        tempColor = UIColorFromRGB(0xade9de);
    }else if ([capacityName isEqual:@"抗压性"]) {
        tempColor = UIColorFromRGB(0xfed7b0);
    }else if ([capacityName isEqual:@"沟通力"]) {
        tempColor = UIColorFromRGB(0xfeccd2);
    }else if ([capacityName isEqual:@"学习力"]) {
        tempColor = UIColorFromRGB(0xbeebb3);
    }else if ([capacityName isEqual:@"诚信值"]) {
        tempColor = UIColorFromRGB(0xf3cef7);
    }
    return tempColor;
}

- (UIColor *)jobCardColorByJobName:(NSString *)jobName {
    UIColor *tempColor = UIColorFromRGB(0xdcdcdc);
    if ([jobName hasPrefix:@"促销"]) {
        tempColor = UIColorFromRGB(0x9fd0e9);
    }else if ([jobName hasPrefix:@"服务"]) {
        tempColor = UIColorFromRGB(0x8bdcd7);
    }else if ([jobName hasPrefix:@"派单"]) {
        tempColor = UIColorFromRGB(0xbfd982);
    }else if ([jobName hasPrefix:@"话务"]) {
        tempColor = UIColorFromRGB(0xe5d798);
    }else if ([jobName hasPrefix:@"安保"]) {
        tempColor = UIColorFromRGB(0x93dae2);
    }else if ([jobName hasPrefix:@"送餐"]) {
        tempColor = UIColorFromRGB(0x9de1b2);
    }else if ([jobName hasPrefix:@"翻译"]) {
        tempColor = UIColorFromRGB(0xe0bfeb);
    }else if ([jobName hasPrefix:@"家教"]) {
        tempColor = UIColorFromRGB(0xe7c4a7);
    }else if ([jobName hasPrefix:@"礼仪"]) {
        tempColor = UIColorFromRGB(0xf5b4a8);
    }else if ([jobName hasPrefix:@"收银"]) {
        tempColor = UIColorFromRGB(0xb9b9f5);
    }else if ([jobName hasPrefix:@"客服"]) {
        tempColor = UIColorFromRGB(0xe7b2d1);
    }
    
    return tempColor;
}

@end
