//
//  RFPartJobManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFPartJobManager.h"
#import "NSString+MyContainsString.h"
static RFPartJobManager *rfPartJobManager;
static NSString *jobData;
@implementation RFPartJobManager
+(id)defaultManager
{
    if (rfPartJobManager == nil) {
        rfPartJobManager = [[RFPartJobManager alloc] init];
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSString *dataStr = [NSString stringWithFormat:@"id=8673717c6c57f3afcb63d2e6d204bb992a2caee0,sn=f78fcfc10a59e1c3ccefee9a8809e1e650330f96,key=Ios,timestamp=%.0f",now];
    NSData* originData = [dataStr dataUsingEncoding:NSASCIIStringEncoding];
    jobData = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return rfPartJobManager;
}

-(void)requestPositionSearchWithJobId:(NSString *)jobId WithJobName:(NSString *)jobName WithIce:(NSString *)ice WithIceUrl:(NSString *)iceUrl Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_PositionSearch_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"id",jobName,@"name",ice,@"ice",iceUrl,@"ice_url",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}

-(void)requestJobListWithPage:(NSString *)page WithLocation:(NSString *)location WithJobId:(NSString *)jobId WithCity:(NSString *)cityId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_JobList_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:page,@"page",location,@"location",jobId,@"type_id",cityId,@"city",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] getV3:url parameters:para success:success error:error failed:failed];
}

-(void)requestJobDetailsWithJobId:(NSString *)jobId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_JobShow_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] getV3:url parameters:para success:success error:error failed:failed];
}

-(void)submitJobApplyWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_JobApply_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] postV3:url parameters:para success:success error:error failed:failed];
}

-(void)searchJobCheckStateWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_JobCheckStateSearch_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid", nil];
    [[RFNetWorkManager defaultManager] getV3:url parameters:para success:success error:error failed:failed];
}

-(void)submitCancelApplyWithJobId:(NSString *)jobId WithUid:(NSString *)uid WithCancelOrigin:(NSString *)orgin WithCancelInfo:(NSString *)info Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_JobCancel_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid",orgin,@"why",info,@"info",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] postV3:url parameters:para success:success error:error failed:failed];
}

-(void)submitCardSignWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_CardSign_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] postV3:url parameters:para success:success error:error failed:failed];
}

-(void)submitCommentWithJobId:(NSString *)jobId WithUid:(NSString *)uid WithClickId:(NSString *)clickId WithPlatform:(NSString *)platform WithMerchants:(NSString *)merchants WithComments:(NSString *)comments Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_Comment_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid",clickId,@"click_id",platform,@"platform",merchants,@"merchants",comments,@"comments",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] postV3:url parameters:para success:success error:error failed:failed];
}

-(void)submitVoilateWithJobId:(NSString *)jobId WithUid:(NSString *)uid Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_Violate_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:jobId,@"job_id",uid,@"uid",jobData,@"job_data", nil];
    [[RFNetWorkManager defaultManager] postV3:url parameters:para success:success error:error failed:failed];
}

-(void)requestCityInfoWithCityName:(NSString *)cityName Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_GETCITYINFO_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:cityName,@"name", nil];
    [[RFNetWorkManager defaultManager] post:url parameters:para success:success error:error failed:failed];
}

-(void)requestCityListSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseJobURL,RF_CITYLIST_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}
@end
