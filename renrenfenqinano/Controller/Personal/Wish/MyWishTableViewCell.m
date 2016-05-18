//
//  MyWishTableViewCell.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyWishTableViewCell.h"

@implementation MyWishTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.connetLabel.text = @"";
    self.dateLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)myWish:(NSDictionary *)dic
{
    self.connetLabel.text = [dic objectForKey:@"goods_name"];
    self.dateLabel.text = [[dic objectForKey:@"create_time"] substringToIndex:10];
}

@end
