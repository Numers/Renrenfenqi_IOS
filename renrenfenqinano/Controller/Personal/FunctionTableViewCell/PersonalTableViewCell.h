//
//  PersonalTableViewCell.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/21.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PersonalTableViewCellProtocol <NSObject>
-(void)clickLeftButton;
-(void)clickMiddleButton;
-(void)clickRightButton;
@end
@interface PersonalTableViewCell : UITableViewCell
{
    UIButton *leftButton;
    UIButton *middleButton;
    UIButton *rightButton;
}
@property(nonatomic, assign) id<PersonalTableViewCellProtocol> delegate;
@end
