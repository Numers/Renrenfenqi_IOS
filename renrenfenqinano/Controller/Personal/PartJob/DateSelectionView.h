//
//  dateSelectionView.h
//  renrenfenqi
//
//  Created by DY on 14/12/26.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateSelectionViewDelegate <NSObject>

- (void)saveDate:(NSDate *)date;

@end

@interface DateSelectionView : UIView

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) id <DateSelectionViewDelegate> delegate;
@property (strong, nonatomic) NSDate *currentDate;

- (id)initDateView;
- (void)show;
- (void)dismiss;

@end
