//
//  CommentLimitControl.h
//  renrenfenqi
//
//  Created by DY on 15/1/14.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentLimitControl : NSObject

@property (nonatomic, strong) NSMutableArray *lastFiveCommentAry;
@property (nonatomic, strong) NSMutableArray *lastFiveCommentTimeAry;
@property (nonatomic, strong) NSDate       *lastCommentTime;
@property (nonatomic, strong) NSCalendar     *calendar;

+(CommentLimitControl *)getLimitControl;
-(id)initCompotent;
// 同一ID以之前发的5条评论内容相同的不能连续发布
-(BOOL)isSameFromLastFiveComments:(NSString *)lastComment;
// 同一ID评论频率间隔不短于5秒
-(BOOL)isCommentsIntervalGreaterThanFiveSecond:(NSDate *)lastCommentTime;
// 2分钟内发言不超过5条
-(BOOL)isCommentCountGreaterThanFiveInTwoMinutes:(NSDate *)nowDate;
// 记录前几次的评论信息
-(void)addCommentContentAndTime:(NSString *)content date:(NSDate *)nowdate;

@end
