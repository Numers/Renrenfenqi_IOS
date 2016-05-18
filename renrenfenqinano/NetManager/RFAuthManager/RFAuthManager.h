//
//  RFAuthManager.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFNetWorkManager.h"
#import "Student.h"
@interface RFAuthManager : NSObject
+(id)defaultManager;

-(void)getStudentAutheticationStatusWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

-(void)getStudentAutheticationInfomationWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

-(void)bookVideoAutheticationWithUid:(NSString *)uid WithToken:(NSString *)token WithQQ:(NSString *)qq WithBookTime:(NSString *)time Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

-(void)submitComfirmInfomationWithUid:(NSString *)uid WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

-(void)submitImageDataWithUid:(NSString *)uid WithToken:(NSString *)token WithImage:(UIImage *)image WithImageType:(NSString *)type Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;

-(void)updateStudentInfomationWithStudent:(Student *)student WithToken:(NSString *)token Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
@end
