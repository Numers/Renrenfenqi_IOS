//
//  URLManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/3.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "URLManager.h"
NSString *BaseURL;
@implementation URLManager
+(void)setUrlWithState:(BOOL)state
{
    if (state) {
        BaseURL = @"https://secure.renrenfenqi.com/pay";
        BaseAuditURL = @"http://audit.renrenfenqi.com";
        BaseJobURL = @"http://job.renrenfenqi.com";
        BaseJobH5URL = @"http://h5.renrenfenqi.com";
        BaseAuthURL = @"http://int.renrenfenqi.com/";
        
        API_BASE = @"http://api.renrenfenqi.com/";
        SECURE_BASE = @"https://secure.renrenfenqi.com/";
        IMAGE_BASE = @"http://img.renrenfenqi.com/";
        JOB_BASE = @"http://job.renrenfenqi.com/";
        API_INT = @"http://int.renrenfenqi.com/";
    }else{
//        BaseURL = @"http://stage.secure.renrenfenqi.com/pay";
//        BaseAuditURL = @"http://stage.audit.renrenfenqi.com";
//        BaseJobURL = @"http://stage.job.renrenfenqi.com/";
//        BaseJobH5URL = @"http://stage.h5.renrenfenqi.com/?offline";
//        BaseAuthURL = @"http://stage.int.renrenfenqi.com/";
//
//        API_BASE = @"http://stage.api.renrenfenqi.com/";
//        SECURE_BASE = @"http://stage.secure.renrenfenqi.com/";
//        IMAGE_BASE = @"http://stage.image.renrenfenqi.com/";
//        JOB_BASE = @"http://stage.job.renrenfenqi.com/";
//        API_INT = @"http://stage.int.renrenfenqi.com/";
        
        BaseURL = @"http://test.secure.renrenfenqi.com/pay";
        BaseAuditURL = @"http://test.audit.renrenfenqi.com";
        BaseJobURL = @"http://test.job.renrenfenqi.com/";
        BaseJobH5URL = @"http://test.h5.renrenfenqi.com/?offline";
        BaseAuthURL = @"http://test.int.renrenfenqi.com/";
        
        API_BASE = @"http://test.api.renrenfenqi.com/";
        SECURE_BASE = @"http://test.secure.renrenfenqi.com/";
        IMAGE_BASE = @"http://test.image.renrenfenqi.com/";
        JOB_BASE = @"http://test.job.renrenfenqi.com/";
        API_INT = @"http://test.int.renrenfenqi.com/";
    }
}
@end
