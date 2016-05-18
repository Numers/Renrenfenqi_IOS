//
//  GoodsDetailSpecViewController.h
//  renrenfenqi
//
//  Created by coco on 15-1-15.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"

/**
    原商品详情页，需要废弃
 */

@interface GoodsDetailSpecViewController : UIViewController <SGFocusImageFrameDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doQuickBuyAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnQuickBuy;


@property (strong, nonatomic) NSString *goodsID;
@property (strong, nonatomic) NSString *jobType;

@end
