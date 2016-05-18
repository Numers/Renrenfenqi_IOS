//
//  SingleHotWishTableViewCell.h
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleHotWishTableViewCellDelegate <NSObject>

- (void)touchPraiseBtn:(int)hotWishId userId:(NSString *)uid;
- (void)goLoginFromHotWish;

@end

@interface SingleHotWishTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsLabel;
@property (weak, nonatomic) IBOutlet UILabel *praiseCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

@property (strong, nonatomic) NSString *rankString;
@property (weak, nonatomic) id<SingleHotWishTableViewCellDelegate> delegate;

- (void)hotWishData:(NSDictionary *)data;

@end
