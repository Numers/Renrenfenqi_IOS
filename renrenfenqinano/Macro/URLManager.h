//
//  URLManager.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/3.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
NSString *BaseURL;
NSString *BaseAuditURL;
NSString *BaseJobURL;
NSString *BaseJobH5URL;
NSString *BaseAuthURL;

NSString *API_BASE;
NSString *SECURE_BASE;
NSString *IMAGE_BASE;
NSString *JOB_BASE;
NSString *API_INT;
@interface URLManager : NSObject
+(void)setUrlWithState:(BOOL)state;
@end
