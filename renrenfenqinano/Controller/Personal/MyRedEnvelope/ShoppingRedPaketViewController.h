//
//  ShoppingRedPaketViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShoppingRedPaketDelegate <NSObject>

// 抵扣红包
- (void)shoppingDeduction:(NSMutableArray*)redPakets totalValue:(int)money;;

@end

@interface ShoppingRedPaketViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *shoppingRedTableview;
@property (weak ,nonatomic) id <ShoppingRedPaketDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *selectedRedPacketArr; // 选中红包容器


@end
