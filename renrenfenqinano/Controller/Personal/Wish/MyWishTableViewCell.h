//
//  MyWishTableViewCell.h
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWishTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *connetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


- (void)myWish:(NSDictionary *)dic;

@end
