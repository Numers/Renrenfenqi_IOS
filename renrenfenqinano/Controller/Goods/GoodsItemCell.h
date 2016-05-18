//
//  GoodsItemCell.h
//  demo150311
//
//  Created by coco on 15-4-7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *GoodsImage;
@property (weak, nonatomic) IBOutlet UILabel *GoodsTitle;
@property (weak, nonatomic) IBOutlet UILabel *GoodsPrice;
@property (weak, nonatomic) IBOutlet UILabel *GoodsMonthSupply;

@end
