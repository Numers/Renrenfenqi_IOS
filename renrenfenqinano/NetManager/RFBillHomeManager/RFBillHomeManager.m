//
//  RFBillHomeManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/6/29.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFBillHomeManager.h"
static RFBillHomeManager *rfBillHomeManager;
@implementation RFBillHomeManager
+(id)defaultManager
{
    if (rfBillHomeManager == nil) {
        rfBillHomeManager = [[RFBillHomeManager alloc] init];
    }
    return rfBillHomeManager;
}

-(void)getBillIndexSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_BillIndex_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}

-(void)getBillInfoSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_MonthBill_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}

-(void)getPerMonthBillInfoWithMonth:(NSString *)month WithType:(NSString *)type Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_BillDetails_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",month,@"year_month", nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}

-(void)getNotRePayBillInfoSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_PendingBill_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}

-(void)getRePayedBillInfoSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_RepaymentBill_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}

-(void)getOrderFirstPriceInfo:(NSString *)businessNo Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_OrderFirstPrice_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:businessNo,@"business_no", nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}

-(void)getCurMonthLateFeeInfoSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_OrderLateFee_API];
    [[RFNetWorkManager defaultManager] get:url parameters:nil success:success error:error failed:failed];
}

-(void)getBillInfoWithBusinessNo:(NSString *)businessNo WithType:(NSString *)type Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseURL,RF_OrderDetail_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",businessNo,@"business_no", nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}
@end
