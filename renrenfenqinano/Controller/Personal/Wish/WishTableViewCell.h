//
//  WishTableViewCell.h
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wishTableViewCellDelegate <NSObject>

- (void) touchCommitBtn:(NSString *)phoneNum goods:(NSString *)goodsName userId:(NSString *)uid;

- (void)goLoginFromWish;

@end

@interface WishTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *goodsNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) id <wishTableViewCellDelegate> delegate;

@end
