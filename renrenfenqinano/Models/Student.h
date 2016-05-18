//
//  Student.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "School.h"
typedef enum {
    UnInput = 1,
    Autheticating,
    AutheticateSuccess,
    AutheticateFailed
}AutheticationStatus;
@interface Student : NSObject
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *identifyCard;
@property(nonatomic, copy) NSString *educationLevel;
@property(nonatomic) NSInteger graduationYear;
@property(nonatomic, strong) School *school;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *dormAddress;
@property(nonatomic, copy) NSString *imageXszUrl; //学生证正面
@property(nonatomic, copy) NSString *imageSfzUrl; //身份证正面
@property(nonatomic, copy) NSString *imageMutiTypeUrl; //多类型图片

@property(nonatomic, copy) NSString *chsiAccount;
@property(nonatomic, copy) NSString *chsiPassword;
@property(nonatomic, copy) NSString *deptDomain;
@property(nonatomic, copy) NSString *deptAccount;
@property(nonatomic, copy) NSString *deptPassword;

@property(nonatomic, copy) NSString *imageDomain;
@property(nonatomic, copy) NSString *videoQQ;
@property(nonatomic, copy) NSString *videoTime;
@property(nonatomic) AutheticationStatus authInfoStatus;
@property(nonatomic) AutheticationStatus authVideoStatus;

-(id)initWithDictionary:(NSDictionary *)dic;
@end
