//
//  WishViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WishTableViewCell.h"
#import "SingleHotWishTableViewCell.h"

@interface WishViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, wishTableViewCellDelegate, SingleHotWishTableViewCellDelegate>


@end
