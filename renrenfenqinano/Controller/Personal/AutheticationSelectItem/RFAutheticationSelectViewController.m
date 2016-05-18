//
//  RFAutheticationSelectViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/26.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFAutheticationSelectViewController.h"
#import "Student.h"
#import "RFAuthManager.h"
#import "AppUtils.h"
#import "RFStudentAutheticationScrollViewController.h"
#import "RFVideoContactInfoViewController.h"
@interface RFAutheticationSelectViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    Student *currentStudent;
    NSString *authInfoName;
    NSString *authVideoName;
}
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation RFAutheticationSelectViewController
-(id)initWithStudent:(Student *)student
{
    self = [super init];
    if (self) {
        currentStudent = student;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    switch (currentStudent.authInfoStatus) {
        case UnInput:
            authInfoName = @"未填写";
            break;
        case Autheticating:
            authInfoName = @"认证中";
            break;
        case AutheticateSuccess:
            authInfoName = @"认证成功";
            break;
        case AutheticateFailed:
            authInfoName = @"认证失败";
            break;
        default:
            break;
    }
    
    switch (currentStudent.authVideoStatus) {
        case UnInput:
            authVideoName = @"未填写";
            break;
        case Autheticating:
            authVideoName = @"认证中";
            break;
        case AutheticateSuccess:
            authVideoName = @"认证成功";
            break;
        case AutheticateFailed:
            authVideoName = @"认证失败";
            break;
        default:
            break;
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestAutheticationStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestAutheticationStatus
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    NSString *token = [loginInfo objectForKey:@"token"];
    if ([AppUtils isLogined:uid]) {
        if ([uid isEqualToString:currentStudent.uid]) {
            [[RFAuthManager defaultManager] getStudentAutheticationStatusWithUid:uid WithToken:token Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *resultDic = (NSDictionary *)responseObject;
                if (resultDic) {
                    NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                    if (dataDic) {
                        currentStudent.authInfoStatus = [[dataDic objectForKey:@"auth_info"] integerValue];
                        currentStudent.authVideoStatus = [[dataDic objectForKey:@"auth_video"] integerValue];
                        authInfoName = [dataDic objectForKey:@"auth_info_name"];
                        authVideoName = [dataDic objectForKey:@"auth_video_name"];
                        [self.tableView reloadData];
                    }
                }
            } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }
}

-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark TableViewDelegate And DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"cell_%ld",(long)indexPath.row]];
    switch (indexPath.row) {
        case 0:
        {
            [cell.textLabel setText:@"学生认证"];
            [cell.detailTextLabel setText:authInfoName];
        }
            break;
        case 1:
        {
            [cell.textLabel setText:@"视频认证"];
            [cell.detailTextLabel setText:authVideoName];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            if (currentStudent.authInfoStatus == Autheticating) {
                [AppUtils showInfo:@"学生认证正在认证中"];
            }else if(currentStudent.authInfoStatus == AutheticateSuccess){
                [AppUtils showInfo:@"学生认证已认证成功"];
            }else{
                RFStudentAutheticationScrollViewController *rfStudentAutheticationScrollVC = [[RFStudentAutheticationScrollViewController alloc] initWithStudent:currentStudent];
                [self.navigationController pushViewController:rfStudentAutheticationScrollVC animated:YES];
            }
        }
            break;
        case 1:
        {
            RFVideoContactInfoViewController *rfVideoContactInfoVC = [[RFVideoContactInfoViewController alloc] initWithStudent:currentStudent];
            [self.navigationController pushViewController:rfVideoContactInfoVC animated:YES];
            return;
            if (currentStudent.authInfoStatus == Autheticating) {
                [AppUtils showInfo:@"学生认证正在认证中,请等待..."];
            }else if(currentStudent.authInfoStatus == UnInput){
                [AppUtils showInfo:@"请先进行学生认证"];
            }else if(currentStudent.authInfoStatus == AutheticateFailed){
                [AppUtils showInfo:@"学生认证失败，请先重新认证学生认证"];
            }else if (currentStudent.authInfoStatus == AutheticateSuccess){
                if (currentStudent.authVideoStatus == Autheticating) {
                    [AppUtils showInfo:@"视频认证正在认证中"];
                }else if (currentStudent.authVideoStatus == AutheticateSuccess){
                    [AppUtils showInfo:@"视频认证已认证成功"];
                }else{
                    RFVideoContactInfoViewController *rfVideoContactInfoVC = [[RFVideoContactInfoViewController alloc] initWithStudent:currentStudent];
                    [self.navigationController pushViewController:rfVideoContactInfoVC animated:YES];
                }
            }
        }
            break;
        default:
            break;
    }
}
@end
