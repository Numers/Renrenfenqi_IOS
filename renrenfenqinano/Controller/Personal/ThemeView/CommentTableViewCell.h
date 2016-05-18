//
//  CommentTableViewCell.h
//  renrenfenqi
//
//  Created by DY on 15/1/13.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *headImageView; // 头像图片
@property (strong, nonatomic) UILabel *nameLabel;         // 昵称
@property (strong, nonatomic) UILabel *dateLabel;         // 日期
@property (strong, nonatomic) UILabel *contentLabel;       // 具体的评论内容

- (void)commentData:(NSDictionary *)dic;
- (int)commentCellHeight;

@end
