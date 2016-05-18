//
//  CCProgressView.m
//  ProgressViewDemo
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import "CCProgressView.h"

@interface CCProgressView()
{
    float _currentLinePointY;
    
    float a;
    float b;
    
    BOOL jia;

}
@end

@implementation CCProgressView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer*)self.layer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
//        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat startAngle =0;
        CGFloat endAngle = 360;
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width/2,frame.size.height/2) radius:self.frame.size.height * 0.5 startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
        
        _circleBG             = [CAShapeLayer layer];
        _circleBG.path        = circlePath.CGPath;
        _circleBG.lineWidth   = DEFAULTLINEWIDTH;
        _circleBG.strokeColor = DEFAULTSTROKECOLOR.CGColor;
        _circleBG.lineCap     = kCALineCapRound;
        _circleBG.fillColor   = [UIColor clearColor].CGColor;
        _circleBG.zPosition   = -1;
        
     
        [self.layer addSublayer:_circleBG];
        
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        maskLayer.path = circlePath.CGPath;
        self.gradientLayer.mask = maskLayer;
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:1]CGColor],(id)[[UIColor clearColor] CGColor], nil];
        self.gradientLayer.locations = @[@0.f, @0.f];
        
        self.gradientLayer.startPoint =CGPointMake(0.5, 1);
        self.gradientLayer.endPoint = CGPointMake(0.5, 0);
        
    }
    
    return self;
}

-(void)setCurrentWaterColor:(UIColor *)currentWaterColor
{
    _currentWaterColor = currentWaterColor;
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[currentWaterColor CGColor],(id)[[UIColor clearColor] CGColor], nil];
}

-(void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    _circleBG.strokeColor = DEFAULTSTROKECOLOR.CGColor;
    [self setNeedsDisplay];
}

-(void)setLineWidth:(NSNumber *)lineWidth
{
    _lineWidth = lineWidth;
    _circleBG.lineWidth   = DEFAULTLINEWIDTH;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    shouldWave = NO;
    if(_theTimer)
    {
        [_theTimer invalidate];
        _theTimer=nil;
    }
    CGFloat rescaledProgress = MIN(MAX(progress, 0.f), 1.f);
    NSArray* newLocations =@[[NSNumber numberWithFloat:rescaledProgress], [NSNumber numberWithFloat:rescaledProgress]];
    
    if (animated)
    {
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = duration;
            animation.delegate = self;
            animation.fromValue = self.gradientLayer.locations;
            animation.toValue = newLocations;
            [self.gradientLayer addAnimation:animation forKey:@"animateLocations"];
        }];
    }
    else
    {
        [self.gradientLayer setNeedsDisplay];
    }
    
    self.gradientLayer.locations = newLocations;
    _currentLinePointY = self.frame.size.height*(1-progress);
    if (_currentWaterColor == nil) {
        _currentWaterColor = [UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:1];
    }
    [self setNeedsDisplay];
}

-(void)beginWave
{
    shouldWave = YES;
    a = 3;//波浪高度
    b = 0;
    jia = NO;
    
    _theTimer=[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}

-(void)animateWave
{
    if (jia) {
        a += 0.1;
    }else{
        a -= 0.1;
    }
    
    
    if (a<=1.5) {
        jia = YES;
    }
    
    if (a>=3) {
        jia = NO;
    }
//
//    
    b+=0.1;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    if (shouldWave) {
        //画水
        for(float x=0;x<=rect.size.width;x++){
            y= a * sin( x/180*M_PI + 4*b/M_PI ) + _currentLinePointY - 3;
            CGPathAddLineToPoint(path, nil, x, y);
        }
    }
    

    CGPathAddLineToPoint(path, nil, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

@end