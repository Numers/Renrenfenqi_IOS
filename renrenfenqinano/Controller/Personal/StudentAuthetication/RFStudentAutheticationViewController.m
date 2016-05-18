//
//  RFStudentAutheticationViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFStudentAutheticationViewController.h"
#import "Student.h"

@interface RFStudentAutheticationViewController ()
{
    Student *currentStudent;
}
@property(nonatomic, strong) IBOutlet UIView *backView;
@property(nonatomic, strong) IBOutlet UIButton *btnNext;

@property(nonatomic, strong) IBOutlet UITextField *txtName;
@property(nonatomic, strong) IBOutlet UITextField *txtIdentifyCard;
@property(nonatomic, strong) IBOutlet UITextField *txtDormAddress;
@property(nonatomic, strong) IBOutlet UITextField *txtClassName;

@property(nonatomic, strong) IBOutlet UIButton *btnEducationLevel;
@property(nonatomic, strong) IBOutlet UIButton *btnGraduationYear;
@property(nonatomic, strong) IBOutlet UIButton *btnSchool;
@end

@implementation RFStudentAutheticationViewController
-(id)initWithStudent:(Student *)student
{
    UIStoryboard *secondStory = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    self = [secondStory instantiateViewControllerWithIdentifier:@"RFStudentAutheticationViewIdentify"];
    if (self) {
        currentStudent = student;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.backView.layer setCornerRadius:5.0f];
    [self.backView.layer setMasksToBounds:YES];
    [self.btnNext.layer setCornerRadius:5.0f];
    [self.btnNext.layer setMasksToBounds:YES];
    
    [self setViewInputValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setViewInputValue
{
    if (currentStudent.name && currentStudent.name.length > 0) {
        _txtName.text = currentStudent.name;
    }
    
    if (currentStudent.identifyCard && currentStudent.identifyCard.length > 0) {
        _txtIdentifyCard.text = currentStudent.identifyCard;
    }
    
    if (currentStudent.educationLevel && currentStudent.educationLevel.length > 0 && ![currentStudent.educationLevel isEqualToString:@"0"]) {
        [_btnEducationLevel setTitle:currentStudent.educationLevel forState:UIControlStateNormal];
        [_btnEducationLevel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnEducationLevel setTitle:@"请选择学历层次" forState:UIControlStateNormal];
        [_btnEducationLevel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if (currentStudent.graduationYear && currentStudent.graduationYear > 0) {
        [_btnGraduationYear setTitle:[NSString stringWithFormat:@"%ld年",(long)currentStudent.graduationYear] forState:UIControlStateNormal];
        [_btnGraduationYear setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnGraduationYear setTitle:@"请选择毕业年份" forState:UIControlStateNormal];
        [_btnGraduationYear setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if (currentStudent.school) {
        [_btnSchool setTitle:currentStudent.school.schoolName forState:UIControlStateNormal];
        [_btnSchool setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [_btnSchool setTitle:@"请选择所在学校" forState:UIControlStateNormal];
        [_btnSchool setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if(currentStudent.className && currentStudent.className.length > 0){
        _txtClassName.text = currentStudent.className;
    }
    
    if (currentStudent.dormAddress && currentStudent.dormAddress.length > 0) {
        _txtDormAddress.text = currentStudent.dormAddress;
    }
}

-(BOOL)validateInput
{
    UIAlertView *alert = nil;
    
    if ((_txtName.text == nil) || (_txtName.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填入姓名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        currentStudent.name = _txtName.text;
    }
    
    if ((_txtIdentifyCard.text == nil) || (_txtIdentifyCard.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填入身份证号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        currentStudent.identifyCard = _txtIdentifyCard.text;
    }
    
    if (!currentStudent.educationLevel || currentStudent.educationLevel.length == 0 || [currentStudent.educationLevel isEqualToString:@"0"]) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择学历层次" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if (!currentStudent.graduationYear || currentStudent.graduationYear == 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择毕业年份" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if (!currentStudent.school) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择毕业年份" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if ((_txtClassName.text == nil) || (_txtClassName.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填入专业和班级" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        currentStudent.className = _txtClassName.text;
    }
    
    if ((_txtDormAddress.text == nil) || (_txtDormAddress.text.length == 0)) {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填入所在宿舍" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }else{
        currentStudent.dormAddress = _txtDormAddress.text;
    }
    return YES;
}

-(IBAction)clickNextBtn:(id)sender
{
    if ([self validateInput]) {
        if ([self.delegate respondsToSelector:@selector(clickNextBtn)]) {
            [self.delegate clickNextBtn];
        }
    }
}

-(IBAction)clickBackBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickBackBtn)]) {
        [self.delegate clickBackBtn];
    }
}

-(IBAction)clickSelectEducationLevelBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSelectEducationLevelBtn)]) {
        [self.delegate clickSelectEducationLevelBtn];
    }
}

-(IBAction)clickSelectGraduationBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSelectGraduationBtn)]) {
        [self.delegate clickSelectGraduationBtn];
    }
}

-(IBAction)clickSelectSchoolBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickSelectSchoolBtn)]) {
        [self.delegate clickSelectSchoolBtn];
    }
}
@end
