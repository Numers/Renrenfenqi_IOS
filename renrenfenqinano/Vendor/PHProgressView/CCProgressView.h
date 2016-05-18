//
//  CCProgressView.h
//  ProgressViewDemo
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define DEFAULTLINEWIDTH 15.0f
#define DEFAULTSTROKECOLOR [UIColor colorWithRed:172/255.0f green:226/255.0f blue:238/255.0f alpha:0.0f]
@interface CCProgressView : UIView
{
    BOOL shouldWave;
}
@property (nonatomic) NSNumber *lineWidth;
@property (nonatomic) CAShapeLayer *circleBG;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *currentWaterColor;
@property (nonatomic, readonly) CAGradientLayer* gradientLayer;
@property (nonatomic , strong)  NSTimer *theTimer;

- (void)setProgress:(CGFloat)progress  animated:(BOOL)animated;
-(void)beginWave;

@end
