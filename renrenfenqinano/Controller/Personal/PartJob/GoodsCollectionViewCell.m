//
//  GoodsCollectionViewCell.m
//  renrenfenqi
//
//  Created by DY on 15/2/25.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "GoodsCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppUtils.h"
#import "CommonVariable.h"

@interface GoodsCollectionViewCell()

@property (strong, nonatomic)UIView      *backgroundView;
@property (strong, nonatomic)UIImageView *goodsImageView;
@property (strong, nonatomic)UILabel     *titleLabel;
@property (strong, nonatomic)UILabel     *priceLabel;
@property (strong, nonatomic)UIImageView *triangleImageView;

@end

@implementation GoodsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

/*
 - (void)initUI {
 self.backgroundColor = [UIColor clearColor];
 float baackgroundViewSide = self.frame.size.width;
 self.backgroundView = [[UIView alloc] init];
 self.backgroundView.frame = CGRectMake(0, 0, baackgroundViewSide, baackgroundViewSide);
 self.backgroundView.backgroundColor = [UIColor whiteColor];
 self.backgroundView.layer.cornerRadius = self.backgroundView.frame.size.width/2;
 self.backgroundView.layer.masksToBounds = YES;
 self.backgroundView.layer.borderColor = UIColorFromRGB(0xebe3e3).CGColor;
 self.backgroundView.layer.borderWidth = 1.0f;
 [self addSubview:self.backgroundView];
 
 self.goodsImageView = [[UIImageView alloc] init];
 self.goodsImageView.frame = CGRectMake(10.0f, 10.0f, self.backgroundView.frame.size.width - 20.0f, self.backgroundView.frame.size.height - 20.0f);
 self.goodsImageView.backgroundColor = [UIColor clearColor];
 [self.backgroundView addSubview:self.goodsImageView];
 
 self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height)];
 self.priceLabel.font = [UIFont systemFontOfSize:10.0f];
 self.priceLabel.textColor = [UIColor whiteColor];
 self.priceLabel.textAlignment = NSTextAlignmentCenter;
 self.priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
 self.priceLabel.numberOfLines = 0;
 [self.backgroundView addSubview:self.priceLabel];
 
 self.titleLabel = [[UILabel alloc] init];
 self.titleLabel.font = [UIFont systemFontOfSize:12.0f];
 self.titleLabel.textColor = [CommonVariable grayFontColor];
 self.titleLabel.textAlignment = NSTextAlignmentCenter;
 CGSize textSize = [@"12" sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
 self.titleLabel.frame = CGRectMake(0, self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height + 10.0f, self.frame.size.width, textSize.height);
 [self addSubview:self.titleLabel];
 
 self.triangleImageView = [[UIImageView alloc] init];
 self.triangleImageView.frame = CGRectMake(0.5*(self.frame.size.width - 18.0f), self.frame.size.height - 9.0f, 18.0f, 9.0f);
 self.triangleImageView.image = [UIImage imageNamed:@"myparttime_body_delta_n@2x.png"];
 self.triangleImageView.hidden = YES;
 [self addSubview:self.triangleImageView];
 }
 */

- (void)initUI {
    self.backgroundColor = [UIColor clearColor];
    
    self.triangleImageView = [[UIImageView alloc] init];
    self.triangleImageView.frame = CGRectMake(0.5*(self.frame.size.width - 18.0f), self.frame.size.height - 9.0f, 18.0f, 9.0f);
    self.triangleImageView.image = [UIImage imageNamed:@"myparttime_body_delta_n@2x.png"];
    self.triangleImageView.hidden = YES;
    [self addSubview:self.triangleImageView];
    
    float backgroundViewSide = self.frame.size.width;
    float tempHeight = self.frame.size.height - self.triangleImageView.frame.size.height;
    float yoffsetFromImageToLabel = 10.0f; // 兼职购商品和商品文字的间距
    CGSize textSize = [@"12" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT12}];
    
    float yoffset = 0.5*(tempHeight - backgroundViewSide - textSize.height - yoffsetFromImageToLabel);
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.frame = CGRectMake(0, yoffset, backgroundViewSide, backgroundViewSide);
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.cornerRadius = self.backgroundView.frame.size.width/2;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.borderColor = UIColorFromRGB(0xebe3e3).CGColor;
    self.backgroundView.layer.borderWidth = 1.0f;
    [self addSubview:self.backgroundView];
    
    self.goodsImageView = [[UIImageView alloc] init];
    self.goodsImageView.frame = CGRectMake(10.0f, 10.0f, self.backgroundView.frame.size.width - 20.0f, self.backgroundView.frame.size.height - 20.0f);
    self.goodsImageView.backgroundColor = [UIColor clearColor];
    [self.backgroundView addSubview:self.goodsImageView];
    
    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height)];
    self.priceLabel.font = [UIFont systemFontOfSize:10.0f];
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    self.priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.priceLabel.numberOfLines = 0;
    [self.backgroundView addSubview:self.priceLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = GENERAL_FONT12;
    self.titleLabel.textColor = [CommonVariable grayFontColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(0, self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height + 10.0f, self.frame.size.width, textSize.height);
    [self addSubview:self.titleLabel];
}

- (void)parttimeGoodsData:(NSDictionary *)dic selectd:(BOOL)isSelectd {
    if (isSelectd) {
        self.goodsImageView.hidden = YES;
        self.priceLabel.hidden = NO;
        self.triangleImageView.hidden = NO;
        self.backgroundView.backgroundColor = UIColorFromRGB(0x8d98a1);
        NSString *price = [AppUtils filterNull:[dic objectForKey:@"prices"]];
        NSString *parttimeDay = [AppUtils filterNull:[dic objectForKey:@"info"]];
        self.priceLabel.text = [NSString stringWithFormat:@"￥%@\n+%@", price, parttimeDay];
    }else{
        self.priceLabel.hidden = YES;
        self.goodsImageView.hidden = NO;
        self.triangleImageView.hidden = YES;
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        NSString *imagePath = [dic objectForKey:@"img"];
        [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]  placeholderImage:[UIImage imageNamed:@"myparttime_body_faile_n.png"]];
    }
    
    self.titleLabel.text = [AppUtils filterNull:[dic objectForKey:@"cname"]];
}

@end
