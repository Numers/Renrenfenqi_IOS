//
//  RFStudentAutheticationViewController.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RFStudentAutheticationViewProtocol <NSObject>
-(void)clickBackBtn;
-(void)clickNextBtn;
-(void)clickSelectEducationLevelBtn;
-(void)clickSelectGraduationBtn;
-(void)clickSelectSchoolBtn;
@end
@class Student;
@interface RFStudentAutheticationViewController : UIViewController
@property(nonatomic, assign) id<RFStudentAutheticationViewProtocol> delegate;
-(id)initWithStudent:(Student *)student;
-(void)setViewInputValue;
@end
