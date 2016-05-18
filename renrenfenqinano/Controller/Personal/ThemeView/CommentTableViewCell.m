//
//  CommentTableViewCell.m
//  renrenfenqi
//
//  Created by DY on 15/1/13.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppUtils.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

// 创建cellUI
- (void)initUI {
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.frame = CGRectMake(15.0f, 15.0f, 35.0f, 35.0f);
    self.headImageView.layer.cornerRadius = 17.5f;
    self.headImageView.layer.masksToBounds = YES;
    [self addSubview:self.headImageView];
    
    CGSize maxNameSize = [@"一二三四五六七八九十" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT14}];
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = GENERAL_FONT14;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.textColor = UIColorFromRGB(0xa2a2a2);
    self.nameLabel.frame = CGRectMake(self.headImageView.frame.origin.x + self.headImageView.frame.size.width + 10.0f, 15.0f, maxNameSize.width, maxNameSize.height);
    [self addSubview:self.nameLabel];
    
    CGSize dateSize = [@"00-00 00:00:00" sizeWithAttributes:@{NSFontAttributeName:GENERAL_FONT12}];
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = GENERAL_FONT12;
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    self.dateLabel.textColor = UIColorFromRGB(0xa2a2a2);
    self.dateLabel.frame = CGRectMake(_MainScreen_Width - dateSize.width -15.0f,
                                      16.0f, dateSize.width, dateSize.height);
    [self addSubview:self.dateLabel];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = GENERAL_FONT14;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.textColor = UIColorFromRGB(0x44444444);
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.dateLabel.frame.size.height + 10.0f, _MainScreen_Width - 15 - self.nameLabel.frame.origin.x, maxNameSize.height);
    [self addSubview:self.contentLabel];
}

// 更新数据
- (void)commentData:(NSDictionary *)dic {
    // 统一字符串服务器发过来的数据，不管原先是什么类型数据
    NSString *imagePath = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
    NSString *nameStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"nikename"]];
    NSString *dateStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"created_at"]];
    NSString *contentStr = [NSString stringWithFormat:@"%@", [dic objectForKey:@"content"]];
    dateStr = [dateStr substringFromIndex:5];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"graphicdetails_body_headportrait_n@2x.png"]];
    self.nameLabel.text = [AppUtils filterNull:nameStr];
    self.dateLabel.text = [AppUtils filterNull:dateStr];
    self.contentLabel.text = [AppUtils filterNull:contentStr];
    
    CGSize maxContentSize = CGSizeMake(_MainScreen_Width - 75.0f, 130.0f);
    CGSize commentSize = [self.contentLabel.text boundingRectWithSize:maxContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:GENERAL_FONT14} context:nil].size;
    
    self.contentLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.dateLabel.frame.size.height + 10.0f, _MainScreen_Width - 15 - self.nameLabel.frame.origin.x, commentSize.height);
}

- (int)commentCellHeight {
    float temp =  self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    return ceilf(temp); // 去小数求整
}

@end
