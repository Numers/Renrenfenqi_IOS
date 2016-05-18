//
//  RFPartJobWebViewJsBridge.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "WebViewJsBridge.h"
@protocol RFPartJobDelegate <NSObject>
@optional
-(NSString *)getJsonLocationInfo;
-(NSString *)getJsonLoginInfo;
-(void)returnCurrentUrl:(NSString *)url;
-(void)pushToSelectCityView;
-(void)lockURL:(NSString *)url;
-(void)unLock;
-(void)applyJobID:(NSString *)jobId;
-(void)commentCompletely;
-(void)saveClientID:(NSString *)clientId;
@end
@interface RFPartJobWebViewJsBridge : WebViewJsBridge
@property(nonatomic, assign) id<RFPartJobDelegate> delegate;
@end
