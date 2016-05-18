//
//  Student.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "Student.h"
@implementation Student
-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (dic) {
        _uid = [dic objectForKey:@"uid"];
        _name = [dic objectForKey:@"name"];
        _identifyCard = [dic objectForKey:@"identity"];
        _educationLevel = [dic objectForKey:@"education_levels"];
        id graduationYear = [dic objectForKey:@"gradion_years"];
        if (graduationYear) {
            _graduationYear = [graduationYear integerValue];
        }
        id schoolId = [dic objectForKey:@"school_id"];
        if (schoolId) {
            _school = [[School alloc] init];
            _school.schoolId = [schoolId integerValue];
            _school.schoolName = [dic objectForKey:@"school_name"];
        }
        _className = [dic objectForKey:@"class"];
        _dormAddress = [dic objectForKey:@"dorm_address"];
        _imageXszUrl = [dic objectForKey:@"img_xsz_url"];
        _imageSfzUrl = [dic objectForKey:@"img_sfz_url"];
        _imageMutiTypeUrl = [dic objectForKey:@"type_img_url"];
        _chsiAccount = [dic objectForKey:@"chsi_account"];
        _chsiPassword = [dic objectForKey:@"chsi_passwd"];
        _deptDomain = [dic objectForKey:@"dept_domain"];
        _deptAccount = [dic objectForKey:@"dept_account"];
        _deptPassword = [dic objectForKey:@"dept_passwd"];
        _imageDomain = [dic objectForKey:@"img_url"];
        _videoQQ = [dic objectForKey:@"video_qq"];
        _videoTime = [dic objectForKey:@"video_time"];
        
        id AuthInfoStatus = [dic objectForKey:@"auth_info"];
        if (AuthInfoStatus) {
            _authInfoStatus = (AutheticationStatus)[AuthInfoStatus integerValue];
        }
        
        id AuthVideoStatus = [dic objectForKey:@"auth_video"];
        if (AuthVideoStatus) {
            _authVideoStatus = (AutheticationStatus)[AuthVideoStatus integerValue];
        }
    }
    return self;
}
@end
