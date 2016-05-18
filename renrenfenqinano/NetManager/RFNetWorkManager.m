//
//  RFNetWorkManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/6/29.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFNetWorkManager.h"
#import "AppUtils.h"
#import "NSString+MyContainsString.h"
static AFHTTPRequestOperationManager *requestManager;
static RFNetWorkManager *rfNetWorkManager;
static NSDictionary *baseDic;
@implementation RFNetWorkManager
+(id)defaultManager
{
    if (rfNetWorkManager == nil) {
        rfNetWorkManager = [[RFNetWorkManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    NSDictionary *userInfo = [AppUtils getUserInfo];
    if (userInfo) {
        baseDic = [NSDictionary dictionaryWithObjectsAndKeys:[[userInfo objectForKey:@"info"] objectForKey:@"uid"],@"uid",[userInfo objectForKey:@"token"],@"token", nil];
    }
    return rfNetWorkManager;
}
-(void)post:(NSString *)url parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)error failed:(ApiFailedCallback)failed
{
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:baseDic];
    if (parameters) {
        for (NSString *key in [parameters allKeys]) {
            [para setObject:parameters[key] forKey:key];
        }
    }
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager POST:encodeUrl parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == 200) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];
}

-(void)postV3:(NSString *)url parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)error failed:(ApiFailedCallback)failed
{
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager POST:encodeUrl parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == SUCCESSREQUEST) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];
}


-(void)get:(NSString *)url parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)error failed:(ApiFailedCallback)failed
{
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:baseDic];
    if (parameters) {
        for (NSString *key in [parameters allKeys]) {
            [para setObject:parameters[key] forKey:key];
        }
    }
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager GET:encodeUrl parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == 200) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];

}

-(void)getV3:(NSString *)url parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)error failed:(ApiFailedCallback)failed
{
    NSString *encodeUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager GET:encodeUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        NSInteger status = [[jsonData objectForKey:@"status"] integerValue];
        if (status == SUCCESSREQUEST) {
            success(operation,responseObject);
        }else{
            error(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failed(operation, error);
    }];
    
}

@end
