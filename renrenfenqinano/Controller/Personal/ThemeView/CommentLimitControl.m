//
//  CommentLimitControl.m
//  renrenfenqi
//
//  Created by DY on 15/1/14.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CommentLimitControl.h"

@implementation CommentLimitControl

static CommentLimitControl *limitControl = nil;

@synthesize lastFiveCommentAry = _lastFiveCommentAry,lastFiveCommentTimeAry = _lastFiveCommentTimeAry,lastCommentTime = _lastCommentTime,calendar = _calendar;

+(CommentLimitControl *)getLimitControl
{
    @synchronized(self)
    {
        if(limitControl == nil)
        {
            limitControl = [[CommentLimitControl alloc] initCompotent];
        }
    }
    return limitControl;
    
}

-(id)initCompotent
{
    if (!_lastFiveCommentAry) {
        _lastFiveCommentAry = [[NSMutableArray alloc] init];
    }
    if (!_calendar) {
        _calendar= [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    }
    if (!_lastFiveCommentTimeAry) {
        _lastFiveCommentTimeAry = [[NSMutableArray  alloc] init];
    }
    return self;
    
}

-(BOOL)isSameFromLastFiveComments:(NSString *)lastComment
{
    if (_lastFiveCommentAry.count == 0) {
        return NO;
    }
    
    if (_lastFiveCommentAry.count>0&&_lastFiveCommentAry.count<5) {
        for (int i = 0; i<_lastFiveCommentAry.count;i++) {
            NSString *comm = [_lastFiveCommentAry objectAtIndex:i];
            if ([lastComment isEqualToString:comm]) {
                return YES;
            }
        }
        
    }
    if (_lastFiveCommentAry.count == 5) {
        for (int i = 0; i<_lastFiveCommentAry.count;i++ ) {
            NSString *comm = [_lastFiveCommentAry objectAtIndex:i];
            if ([lastComment isEqualToString:comm]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isCommentsIntervalGreaterThanFiveSecond:(NSDate *)nowDate
{
    if (_lastFiveCommentTimeAry.count == 0) {
        _lastCommentTime = nowDate;
        return YES;
    }
    
    if (_lastFiveCommentTimeAry.count > 0) {
        _lastCommentTime = (NSDate *)[_lastFiveCommentTimeAry objectAtIndex:_lastFiveCommentTimeAry.count-1];
    }
    
    NSInteger second = [[_calendar components:NSMinuteCalendarUnit fromDate:_lastCommentTime  toDate:nowDate  options:0] second];
    if (second<5) {
        
        return NO;
    }else{
        
        return YES;
    }
    
    return YES;
}

-(BOOL)isCommentCountGreaterThanFiveInTwoMinutes:(NSDate *)nowDate
{
    if (_lastFiveCommentTimeAry.count == 5) {
        NSDate *firstDate = [_lastFiveCommentTimeAry objectAtIndex:0];
        NSInteger minute = [[_calendar components:NSMinuteCalendarUnit fromDate:firstDate  toDate:nowDate  options:0] minute];
        if (minute > 2) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

-(void)addCommentContentAndTime:(NSString *)content date:(NSDate *)nowdate
{
    if (_lastFiveCommentAry.count < 5 ) {
        [_lastFiveCommentAry addObject:content];
    }
    if (_lastFiveCommentAry.count == 5) {
        [_lastFiveCommentAry removeObjectAtIndex:0];
        [_lastFiveCommentAry addObject:content];
    }
    if (_lastFiveCommentTimeAry.count < 5) {
        [_lastFiveCommentTimeAry addObject:nowdate];
    }
    if (_lastFiveCommentTimeAry.count == 5) {
        [_lastFiveCommentTimeAry removeObjectAtIndex:0];
        [_lastFiveCommentTimeAry addObject:nowdate];
    }
}


@end
