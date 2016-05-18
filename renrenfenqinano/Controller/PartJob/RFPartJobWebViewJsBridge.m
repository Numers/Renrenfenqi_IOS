//
//  RFPartJobWebViewJsBridge.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFPartJobWebViewJsBridge.h"

@implementation RFPartJobWebViewJsBridge
-(NSString *)getLocation
{
    if ([self.delegate respondsToSelector:@selector(getJsonLocationInfo)]) {
        return [self.delegate getJsonLocationInfo];
    }
    return nil;
}

-(NSString *)login
{
    if ([self.delegate respondsToSelector:@selector(getJsonLoginInfo)]) {
        return [self.delegate getJsonLoginInfo];
    }
    return nil;
}

-(void)selectCity
{
    if ([self.delegate respondsToSelector:@selector(pushToSelectCityView)]) {
        [self.delegate pushToSelectCityView];
    }
}

-(void)comment:(NSArray *)parameters
{
    if ([self.delegate respondsToSelector:@selector(commentCompletely)]) {
        if (parameters && parameters.count > 0) {
            NSString *redirectUrl = [parameters objectAtIndex:0];
            if ([redirectUrl isEqualToString:@"index"]) {
                [self.delegate commentCompletely];
            }
        }
    }
}

-(void)lock:(NSArray *)parameters
{
    if (parameters && parameters.count >=2) {
        BOOL isLock = [[parameters objectAtIndex:0] boolValue];
        if (isLock) {
            if ([self.delegate respondsToSelector:@selector(lockURL:)]) {
                NSString *lockUrl = [parameters objectAtIndex:1];
                [self.delegate lockURL:lockUrl];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(unLock)]) {
                [self.delegate unLock];
            }
        }
    }
}

-(void)sendClientId:(NSArray *)parameters
{
    if ([self.delegate respondsToSelector:@selector(saveClientID:)]) {
        if (parameters && parameters.count > 0) {
            NSString *clientId = [parameters objectAtIndex:0];
            [self.delegate saveClientID:clientId];
        }
    }
}

-(void)setUrl:(NSArray *)parameters
{
    if ([self.delegate respondsToSelector:@selector(returnCurrentUrl:)]) {
        if (parameters && parameters.count > 0) {
            NSString *url = [parameters objectAtIndex:0];
            [self.delegate returnCurrentUrl:url];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(applyJobID:)]) {
        if (parameters && parameters.count > 1) {
            NSString *jobId = [parameters objectAtIndex:1];
            if (jobId) {
                [self.delegate applyJobID:jobId];
            }
        }
    }
}
@end
