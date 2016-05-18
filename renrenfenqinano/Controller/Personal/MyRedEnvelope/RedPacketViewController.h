//
//  RedPacketViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/22.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeductionViewController.h"


typedef enum {
    RedPacketStatus_All = 0,
    RedPacketStatus_NotUsed,
    RedPacketStatus_Used,
    RedPacketStatus_Reserved,
    RedPacketStatus_Overdue,
}RedPacketStatus;

@interface RedPacketViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,DeductionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *redPacketList;

@end
