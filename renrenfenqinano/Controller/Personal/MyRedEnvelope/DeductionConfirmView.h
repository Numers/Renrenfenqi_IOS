//
//  DeductionConfirmView.h
//  renrenfenqi
//
//  Created by DY on 14/11/28.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeductionConfirmView : UIView

@property (strong, nonatomic) dispatch_block_t dismissBlock;
@property (strong, nonatomic) dispatch_block_t confirmBlock;

- (id)initWithData:(int)deduction;
- (void)show;

@end
