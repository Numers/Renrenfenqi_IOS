//
//  RFAuthManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFAuthManager.h"
static RFAuthManager *rfAuthManager;
@implementation RFAuthManager
+(id)defaultManager
{
    if (rfAuthManager == nil) {
        rfAuthManager = [[RFAuthManager alloc] init];
    }
    return rfAuthManager;
}

-(void)getStudentAutheticationStatusWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_AutheticationStatus_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",token,@"token",@"ios",@"client", nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}

-(void)getStudentAutheticationInfomationWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_StudentAuthInfo_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",token,@"token",@"ios",@"client",nil];
    [[RFNetWorkManager defaultManager] get:url parameters:para success:success error:error failed:failed];
}

-(void)bookVideoAutheticationWithUid:(NSString *)uid WithToken:(NSString *)token WithQQ:(NSString *)qq WithBookTime:(NSString *)time Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_VideoAuthBook_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",token,@"token",@"ios",@"client",qq,@"video_qq",time,@"video_time",nil];
    [[RFNetWorkManager defaultManager] post:url parameters:para success:success error:error failed:failed];
}

-(void)submitComfirmInfomationWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_AuthComfirmSubmit_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",token,@"token",@"ios",@"client", nil];
    [[RFNetWorkManager defaultManager] post:url parameters:para success:success error:error failed:failed];
}

-(void)submitImageDataWithUid:(NSString *)uid WithToken:(NSString *)token WithImage:(UIImage *)image WithImageType:(NSString *)type Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString *base64String = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_AuthImagePost_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",token,@"token",@"ios",@"client",base64String,@"load",type,@"type",nil];
    [[RFNetWorkManager defaultManager] post:url parameters:para success:success error:error failed:failed];
}

-(void)updateStudentInfomationWithStudent:(Student *)student WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseAuthURL,RF_AuthStudentTextSubmit_API];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:student.uid,@"uid",token,@"token",@"ios",@"client",student.name,@"name",student.identifyCard,@"identity",student.educationLevel,@"education_levels",[NSString stringWithFormat:@"%ld",(long)student.graduationYear],@"gradion_years",[NSString stringWithFormat:@"%ld",(long)student.school.schoolId],@"school_id",student.className,@"class",student.dormAddress,@"dorm_address", nil];
    [[RFNetWorkManager defaultManager] post:url parameters:para success:success error:error failed:failed];
}
@end
