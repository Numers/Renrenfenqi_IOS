//
//  RFDatePickViewController.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RFDatePickViewProtocol <NSObject>
-(void)pickDate:(NSDate *)date WithIdentify:(id)identify;
@end
@interface RFDatePickViewController : UIViewController
@property(nonatomic, assign) id<RFDatePickViewProtocol> delegate;
-(id)initWithDate:(NSTimeInterval)time WithStartTime:(NSTimeInterval)startTime WithEndTime:(NSTimeInterval)endTime WithPickViewIdentify:(id)identify;
-(void)setDatePickMode:(UIDatePickerMode)mode;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
