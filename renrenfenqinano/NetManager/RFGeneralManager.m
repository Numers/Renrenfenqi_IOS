//
//  RFGeneralManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFGeneralManager.h"
#import "RFNetWorkHelper.h"
#import "JSONKit.h"
#import "AppUtils.h"
#import "OpenUDID.h"
#import "AppDelegate.h"
#import "URLManager.h"
static AFHTTPRequestOperationManager *requestManager;
static RFGeneralManager *rfGeneralManager;
@implementation RFGeneralManager
+(id)defaultManager
{
    if (rfGeneralManager == nil) {
        rfGeneralManager = [[RFGeneralManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return rfGeneralManager;
}
-(void)sendClientIdSuccess:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSDictionary *userInfo = [AppUtils getUserInfo];
    NSString *uid = [[userInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([uid isEqualToString:@"-1"]) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.registerID == nil) {
        return;
    }
    NSString *appid = [OpenUDID valueWithError:nil];
    NSString *URL = [NSString stringWithFormat:@"%@%@",BaseAuditURL,RF_PushClientIdSend_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.registerID,@"client_id",appid,@"appid",@"2",@"type",uid,@"user_id", nil];
    [requestManager GET:URL parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSInteger code = [[resultDic objectForKey:@"code"] integerValue];
            if (code == 200) {
                success(operation, responseObject);
            }else{
                error(operation, responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];
}

-(void)getGlovalVarWithVersion
{
    [URLManager setUrlWithState:NO];
    return;
    NSNumber *isProductNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppIsProduct"];
    if (isProductNum && [isProductNum integerValue] == 1) {
        [URLManager setUrlWithState:YES];
        return;
    }
    NSString *appVersion = [AppUtils appVersion];
    NSString *url = [NSString stringWithFormat:@"https://secure.renrenfenqi.com/pay/isProduction?version=%@",appVersion];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:TimeOut];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requestOperation setResponseSerializer:responseSerializer];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSDictionary *resultDic = (NSDictionary *)[requestOperation responseObject];
    if (resultDic) {
        NSInteger status = [[resultDic objectForKey:@"status"] integerValue];
        if (status == 200) {
            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
            if (dataDic) {
                NSInteger isproduction = [[dataDic objectForKey:@"isProduction"] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:isproduction] forKey:@"AppIsProduct"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (isproduction == 1) {
                    [URLManager setUrlWithState:YES];
                    return;
                }else{
                    [URLManager setUrlWithState:NO];
                    return;
                }
            }
        }
    }
    [URLManager setUrlWithState:YES];
}
@end
