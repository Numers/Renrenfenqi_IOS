//
//  PHAuraView.h
//  PocketHealth
//
//  Created by macmini on 15-1-28.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHAuraView : UIView
@property(nonatomic) UIColor *strokeColor;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) CGFloat startAngle;
@property(nonatomic) CGFloat endAngle;

- (void)setStrokeEnd:(CGFloat)strokeEnd animated:(BOOL)animated;
-(void)beginGenerateView;
@end
