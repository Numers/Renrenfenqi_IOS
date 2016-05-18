//
//  TakeRedPacketView.h
//  renrenfenqi
//
//  Created by DY on 14/11/27.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakeRedPacketView : UIView

@property (strong, nonatomic) dispatch_block_t dismissBlock;
@property (strong, nonatomic) dispatch_block_t lookMyRedPacketBlock;

- (id)initWithView:(CGRect)frame;
- (void)show;

@end
