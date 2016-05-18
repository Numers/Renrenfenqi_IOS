//
//  PHProgressView.m
//  Progress
//
//  Created by macmini on 15-1-22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHProgressView.h"
#import "CCProgressView.h"
#import "PHAuraView.h"
#define TimeDuration 0.003f
#define LabelHeight 30.0f
#define RotationDuration 0.6f
#define MarginLeft 19.4f

static CGFloat currentProgress;
@implementation PHProgressView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        currentProgress = 0.f;
        ccProgressView = [[CCProgressView alloc] initWithFrame:CGRectMake(MarginLeft, MarginLeft, frame.size.width-MarginLeft*2, frame.size.height-MarginLeft*2)];
        [self addSubview:ccProgressView];
        
        scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2  - LabelHeight, frame.size.width, LabelHeight)];
        [scoreLabel setTextColor:[UIColor whiteColor]];
        [scoreLabel setTextAlignment:NSTextAlignmentCenter];
        [scoreLabel setFont:[UIFont systemFontOfSize:27]];
        [self addSubview:scoreLabel];
        
        detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2 + LabelHeight, frame.size.width, LabelHeight)];
        [detailsLabel setHidden:YES];
        [detailsLabel setTextColor:[UIColor whiteColor]];
        [detailsLabel setTextAlignment:NSTextAlignmentCenter];
        [detailsLabel setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:detailsLabel];
        
        [self addCircleLayer];
    }
    return self;
}

-(NSMutableAttributedString *)generateAttriuteStringWithScore:(float)progressScore WithColor:(UIColor *)color
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f",progressScore]];
    NSRange range;
    range.location = 0;
    range.length = attrString.length;
    [attrString beginEditing];
//    [attrString addAttribute: NSForegroundColorAttributeName
//                       value:color
//                       range:range];
    [attrString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont systemFontOfSize:41],NSFontAttributeName, nil] range:range];
    [attrString endEditing];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"分"];
    NSRange range1;
    range1.location = 0;
    range1.length = att.length;
    [att beginEditing];
    [att addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[UIFont systemFontOfSize:24],NSFontAttributeName, nil] range:range1];
    [att endEditing];

    [attrString appendAttributedString:att];
    return attrString;
}

- (void)addCircleLayer
{
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/2) radius:self.frame.size.height * 0.5 - 14 startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(360) clockwise:YES];
    
    CAShapeLayer *circleLayer  = [CAShapeLayer layer];
    circleLayer.path        = circlePath.CGPath;
    circleLayer.lineWidth   = LINEWIDTH;
    circleLayer.strokeColor = [CircleStrokeColor CGColor];
    circleLayer.lineCap     = kCALineCapRound;
    circleLayer.fillColor   = [UIColor clearColor].CGColor;
    circleLayer.zPosition   = -1;
    
    
    [self.layer addSublayer:circleLayer];
}


-(void)auraviewRotation
{
    if (phAuraView == nil) {
        phAuraView = [[PHAuraView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [phAuraView beginGenerateView];
        [self addSubview:phAuraView];
        [phAuraView setStrokeEnd:1.0f animated:NO];
        [self startRotation];
    }
}

-(void)startRotation
{
    shouldRotation = NO;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = RotationDuration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100.0f;
    rotationAnimation.delegate = self;
    
    [phAuraView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (phAuraView != nil) {
        [phAuraView.layer removeAllAnimations];
    }
    shouldRotation = YES;
}

-(void)stopRotation
{
    if (phAuraView != nil) {
        [phAuraView setHidden:YES];
        [phAuraView.layer removeAllAnimations];
        [phAuraView removeFromSuperview];
        phAuraView = nil;
    }
}

-(void)setDynamicProgress:(CGFloat)progress
{
    if (progress > 0) {
        currentProgress = progress;
        score = progress;
    }else{
        currentProgress = 0.05;
        score = 0.05;
    }

    UIColor *color = [self waterColorWithProgress:progress WithAlpha:1.f];
    [ccProgressView setCurrentWaterColor:color];
    [ccProgressView setProgress:progress/100.0f animated:NO];
    
    [detailsLabel setText:[self getHealthState]];
    [scoreLabel setAttributedText:[self generateAttriuteStringWithScore:progress WithColor:[UIColor whiteColor]]];
    [detailsLabel setHidden:NO];
    [scoreLabel setHidden:NO];
    [self stopRotation];
    [ccProgressView beginWave];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if ((myTimer == nil)|| (![myTimer isValid])) {
        [detailsLabel setHidden:YES];
        [scoreLabel setHidden:YES];
        if (progress > 0) {
            score = progress;
        }else{
            score = 0.05;
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"Animate"];
    
        inilizedOver = NO;
        
    
        myTimer = [NSTimer scheduledTimerWithTimeInterval:TimeDuration target:self selector:@selector(startUpdate:) userInfo:userInfo repeats:YES];
        [myTimer fire];
    }
}

-(void)startUpdate:(NSTimer *)timer
{
    if (!inilizedOver) {
        if (currentProgress > DownProgressInteval) {
            [scoreLabel setAttributedText:[self generateAttriuteStringWithScore:currentProgress WithColor:[UIColor whiteColor]]];
            BOOL animate = [[[timer userInfo] objectForKey:@"Animate"] boolValue];
            UIColor *color = [self waterColorWithProgress:currentProgress WithAlpha:1.0f];
            [ccProgressView setCurrentWaterColor:color];
            if (phAuraView != nil) {
                [phAuraView setStrokeColor:[self waterColorWithProgress:currentProgress WithAlpha:0.7f]];
                if (shouldRotation) {
                    [self startRotation];
                }
            }
            [ccProgressView setProgress:currentProgress/100.0f animated:animate];
            currentProgress = currentProgress - DownProgressInteval;
            return;
        }else{
            inilizedOver = YES;
        }
    }
    
    if (currentProgress >= score) {
        [detailsLabel setText:[self getHealthState]];
        [detailsLabel setHidden:NO];
        [scoreLabel setHidden:NO];
        [timer invalidate];
        timer = nil;
        [self stopRotation];
        [ccProgressView beginWave];
        
        if ([self.delegate respondsToSelector:@selector(stopAnimateProgress)]) {
            [self.delegate stopAnimateProgress];
        }
        return;
    }
    [self auraviewRotation];
    [scoreLabel setAttributedText:[self generateAttriuteStringWithScore:currentProgress WithColor:[UIColor whiteColor]]];
    BOOL animate = [[[timer userInfo] objectForKey:@"Animate"] boolValue];
    UIColor *color = [self waterColorWithProgress:currentProgress WithAlpha:1.f];
    [ccProgressView setCurrentWaterColor:color];
    if (phAuraView != nil) {
        [phAuraView setStrokeColor:[self waterColorWithProgress:currentProgress WithAlpha:0.7f]];
        if (shouldRotation) {
            [self startRotation];
        }
    }
    [ccProgressView setProgress:currentProgress/100.0f animated:animate];
    currentProgress = currentProgress + ProgressInterval;
}

void HSVtoRGB(float *r, float *g, float *b, float h, float s, float v)
{
    int i;
    float f, p, q, t;
    if( s == 0 ) {
        // achromatic (grey)
        *r = *g = *b = v;
        return;
    }
    h /= 60;            // sector 0 to 5
    i = floor( h );
    f = h - i;          // factorial part of h
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    switch( i ) {
        case 0:
            *r = v;
            *g = t;
            *b = p;
            break;
        case 1:
            *r = q;
            *g = v;
            *b = p;
            break;
        case 2:
            *r = p;
            *g = v;
            *b = t;
            break;
        case 3:
            *r = p;
            *g = q;
            *b = v;
            break;
        case 4:
            *r = t;
            *g = p;
            *b = v;
            break;
        default:        // case 5:
            *r = v;
            *g = p;
            *b = q;
            break;
    }
}

-(UIColor *)waterColorWithProgress:(float)progress WithAlpha:(float)alpha
{
    float fs = progress/100;
    float r,g,b,h,s,v;
    h = 160*fs - 40.f;
    s = 0.85;
    v = 0.85;
    HSVtoRGB(&r, &g, &b, h, s, v);
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    return color;
}

-(NSString *)getHealthState
{
    if (score < 80) {
        return @"亚健康状态";
    }
    
    if (score < 90) {
        return @"身体健康";
    }
    
    if (score < 100) {
        return @"身体很健康";
    }
    return nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
