//
//  DeductionViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeductionDelegate <NSObject>

@optional
// 抵扣红包
- (void)deduction:(NSMutableArray*)redPakets;
// 不是自动还款调用
- (void)repaymentRedData:(NSMutableArray*)redPakets totalValue:(int)money;

@end

@interface DeductionViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnUseRule;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITableView *redPacketList;

@property (weak ,nonatomic) id <DeductionDelegate> delegate;
@property (assign, nonatomic) NSDictionary *billDic;

@property (strong, nonatomic) NSMutableArray *selectedRedPacketArr; // 选中红包容器


@end
