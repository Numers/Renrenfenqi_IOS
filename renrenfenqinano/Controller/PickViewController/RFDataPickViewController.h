//
//  RFDataPickViewController.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RFDataPickViewProtocol <NSObject>
-(void)pickData:(id)data WithIdentify:(id)identify;
@end
@interface RFDataPickViewController : UIViewController
@property(nonatomic, assign) id<RFDataPickViewProtocol> delegate;

-(id)initWithDataArray:(NSArray *)dataArray WithTitleArray:(NSArray *)titleArray WithIdentify:(id)identify;
-(void)setSelectRow:(NSInteger)row;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
