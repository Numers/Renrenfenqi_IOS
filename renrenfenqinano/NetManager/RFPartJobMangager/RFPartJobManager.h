//
//  RFPartJobManager.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFNetWorkManager.h"
@interface RFPartJobManager : NSObject
+(id)defaultManager;
//职位查询
-(void)requestPositionSearchWithJobId:(NSString *)jobId WithJobName:(NSString *)jobName WithIce:(NSString *)ice WithIceUrl:(NSString *)iceUrl Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
//岗位列表
-(void)requestJobListWithPage:(NSString *)page WithLocation:(NSString *)location WithJobId:(NSString *)jobId WithCity:(NSString *)cityId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
//岗位详情
-(void)requestJobDetailsWithJobId:(NSString *)jobId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//报名
-(void)submitJobApplyWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//取消报名
-(void)submitCancelApplyWithJobId:(NSString *)jobId WithUid:(NSString *)uid WithCancelOrigin:(NSString *)orgin WithCancelInfo:(NSString *)info Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//打卡签到
-(void)submitCardSignWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//打卡或评论
-(void)submitCommentWithJobId:(NSString *)jobId WithUid:(NSString *)uid WithClickId:(NSString *)clickId WithPlatform:(NSString *)platform WithMerchants:(NSString *)merchants WithComments:(NSString *)comments Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//违约不去了
-(void)submitVoilateWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//查询订单审核状态
-(void)searchJobCheckStateWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//根据城市名获取城市信息
-(void)requestCityInfoWithCityName:(NSString *)cityName Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

//获取城市列表
-(void)requestCityListSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
@end
