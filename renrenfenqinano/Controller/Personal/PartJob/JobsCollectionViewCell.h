//
//  JobsCollectionViewCell.h
//  renrenfenqi
//
//  Created by DY on 15/2/25.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobsCollectionViewCell : UICollectionViewCell

//- (void)parttimeJobsData:(NSDictionary *)dic;
- (void)parttimeJobsData:(NSDictionary *)dic specialCard:(BOOL)isSpecialCard;

@end
