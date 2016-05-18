//
//  PHProgressView.h
//  Progress
//
//  Created by macmini on 15-1-22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DownProgressInteval 0.3
#define ProgressInterval 0.1
#define LINEWIDTH 4.f
#define CircleStrokeColor [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.3f]
@class CCProgressView,PHAuraView;
@protocol PHProgressViewDelegate <NSObject>

-(void)stopAnimateProgress;

@end
@interface PHProgressView : UIView
{
    CCProgressView *ccProgressView;
    PHAuraView *phAuraView;
    UILabel *scoreLabel;
    UILabel *detailsLabel;
    CGFloat score;
    NSString *detailText;
    BOOL inilizedOver;
    NSTimer *myTimer;
    
    BOOL shouldRotation;
}

@property(nonatomic, assign) id<PHProgressViewDelegate> delegate;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
-(void)setDynamicProgress:(CGFloat)progress;
@end
