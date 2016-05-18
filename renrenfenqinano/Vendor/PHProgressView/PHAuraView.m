//
//  PHAuraView.m
//  PocketHealth
//
//  Created by macmini on 15-1-28.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAuraView.h"
#import <POP/POP.h>
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define DefaultStrokeColor [UIColor greenColor]

@interface PHAuraView()
{
    CAGradientLayer *gradientLayer;
}
@property(nonatomic) CAShapeLayer *circleLayer;
- (void)addCircleLayer;
- (void)animateToStrokeEnd:(CGFloat)strokeEnd;
@end
@implementation PHAuraView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.width == frame.size.height, @"A circle must have the same height and width.");
        _startAngle = 0;
        _endAngle = 65;
        _lineWidth = 3.f;
        _strokeColor = DefaultStrokeColor;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)beginGenerateView
{
    [self addCircleLayer];
}

#pragma mark - Instance Methods

- (void)setStrokeEnd:(CGFloat)strokeEnd animated:(BOOL)animated
{
    if (animated) {
        [self animateToStrokeEnd:strokeEnd];
        return;
    }
    [self.circleLayer setStrokeEnd:strokeEnd];
//    CGFloat allAngle = _endAngle - _startAngle;
//    CGFloat pieceValue = 1.0f/allAngle;
//    for (CGFloat i = 1; i <= allAngle; i ++) {
//        [self setLineWidth:10 * i / allAngle];
//        [self.circleLayer setStrokeStart:(i - 1) * pieceValue];
//        [self.circleLayer setStrokeEnd:i * pieceValue];
//    }
}

#pragma mark - Property Setters

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

#pragma mark - Private Instance methods

- (void)addCircleLayer
{
    CGFloat radius = CGRectGetWidth(self.bounds)/2 - _lineWidth/2;
    self.circleLayer = [CAShapeLayer layer];
    CGRect rect = CGRectMake(_lineWidth/2, _lineWidth/2, radius * 2, radius * 2);
    //    self.circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect
    //                                                  cornerRadius:radius].CGPath;
    self.circleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:radius startAngle:DEGREES_TO_RADIANS(_startAngle) endAngle:DEGREES_TO_RADIANS(_endAngle) clockwise:YES].CGPath;
    self.circleLayer.lineWidth = _lineWidth;
//    self.circleLayer.strokeColor = _strokeColor.CGColor;
    self.circleLayer.fillColor = nil;
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:self.circleLayer];
//    [self colorDifferent];
//    [self.layer addSublayer:gradientLayer];
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    self.circleLayer.lineWidth = lineWidth;
    _lineWidth = lineWidth;
}

- (void)animateToStrokeEnd:(CGFloat)strokeEnd
{
    POPSpringAnimation *strokeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    strokeAnimation.toValue = @(strokeEnd);
    strokeAnimation.springBounciness = 12.f;
    strokeAnimation.removedOnCompletion = NO;
    [self.circleLayer pop_addAnimation:strokeAnimation forKey:@"layerStrokeAnimation"];
}

//-(void)colorDifferent
//{
////    CALayer *gradientLayer = [CALayer layer];
//    gradientLayer =  [CAGradientLayer layer];
//    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[_strokeColor CGColor], nil]];
//    [gradientLayer setLocations:@[@0.1,@0.5,@1 ]];
//    [gradientLayer setStartPoint:CGPointMake(0.5, 0)];
//    [gradientLayer setEndPoint:CGPointMake(0.5, 1)];
//    [gradientLayer setMask:self.circleLayer];
//}

-(void)drawRect:(CGRect)rect
{
    self.circleLayer.strokeColor = _strokeColor.CGColor;
//    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[_strokeColor CGColor], nil]];
}
@end
