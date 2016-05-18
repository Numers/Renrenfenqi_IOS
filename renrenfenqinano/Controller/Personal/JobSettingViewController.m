//
//  JobSettingViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-25.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "JobSettingViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "ImprovePersonalInfoViewController.h"
#import "ImprovePersonalInfoViewController2.h"

@interface JobSettingViewController ()
{
    BOOL _haveJobSetting;
    BOOL _haveUserInfo;
    
    NSDictionary *_myjobSetting;
    NSDictionary *_accountInfo;
    
    float _viewWidth;
    float _viewHeight;
    
    BOOL _nodata;
    
    UIStoryboard *_secondStorybord;
}

@end

@implementation JobSettingViewController

- (void)getMyJobSettingFromAPI:(BOOL)isRefresh
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]};
    NSLog(@"%@", [[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]);
//    NSDictionary *parameters = @{@"uid":@"5"};
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_MYJOB_SETTING] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
                MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _nodata = NO;
            self.myjobSetting = [jsonData objectForKey:@"data"];
            if (![self.myjobSetting objectForKey:@"state"]) {
                //有设置
                _haveJobSetting = YES;
                _haveUserInfo = YES;
                self.btnModifySetting.hidden = NO;
                [self.tableJobSetting reloadData];
            }
            else if ([self.myjobSetting objectForKey:@"state"] && ([[NSString stringWithFormat:@"%@", [self.myjobSetting objectForKey:@"is_info"]] isEqualToString:@"1"]))
            {
                _haveJobSetting = NO;
                _haveUserInfo = YES;
                
                if (!isRefresh) {
                    ImprovePersonalInfoViewController2 *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
                    vc.theViewClass = [JobSettingViewController class];
                    [AppUtils pushPage:self targetVC:vc];
                }
                
                [self.tableJobSetting reloadData];
            }
            else
            {
                //没设置
                _haveJobSetting = NO;
                [self.tableJobSetting reloadData];
            }
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)refreshMyJobSetting
{
    [self getMyJobSettingFromAPI:YES];
}

- (void)getMyJobSetting
{
    [self getMyJobSettingFromAPI:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    UIView *theLine = [AppUtils makeLine:_viewWidth theTop:63.0];
    [self.view addSubview:theLine];
    
    _haveJobSetting = NO;
    _haveUserInfo = NO;
    self.btnModifySetting.hidden = YES;
    _nodata = YES;
    
    _accountInfo = [AppUtils getUserInfo];
    
    self.tableJobSetting.delegate = self;
    self.tableJobSetting.dataSource = self;
    self.tableJobSetting.tableFooterView = [UIView new];
    self.tableJobSetting.backgroundColor = [UIColor clearColor];
    if ([self.tableJobSetting respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableJobSetting setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableJobSetting respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableJobSetting setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //TODO JZ 修改通知名称
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshMyJobSetting)
                                                 name:NOTIFY_JOBSETTING_OK
                                               object:nil];
    
    [self performSelector:@selector(getMyJobSetting) withObject:self afterDelay:0.5];
//    [self getMyJobSettingFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    NSDictionary *theOrder = [self.orders objectAtIndex:indexPath.row];

    
    if ((!_haveJobSetting) && (!_haveUserInfo)) {
        //TODO JZ 到简历设置
        ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
        vc.isSkip = NO;
        vc.theViewClass = [JobSettingViewController class];
        [AppUtils pushPage:self targetVC:vc];
    }
    else if((!_haveJobSetting) && _haveUserInfo)
    {
        ImprovePersonalInfoViewController2 *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
        vc.theViewClass = [JobSettingViewController class];
        [AppUtils pushPage:self targetVC:vc];
    }
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 35.0;
    
    if (_haveJobSetting) {
        switch (indexPath.row) {
            case 1:
            {
                height = 185.0;
            }
                break;
            case 2:
            {
                height = 10.0;
            }
                break;
            case 4:
            {
                height = 90.0;
                
                //TODO
                NSString *jobIntentStr = [self makeJobIntentStr];
                NSDictionary *attributes = @{NSFontAttributeName: GENERAL_FONT13};
                // NSString class method: boundingRectWithSize:options:attributes:context is
                // available only on ios7.0 sdk.
                CGRect rect = [jobIntentStr boundingRectWithSize:CGSizeMake(_viewWidth - 30.0 - 65.0, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:attributes
                                                         context:nil];
                height = 65.0 + MAX(rect.size.height, 21.0);
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        height = 43;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_nodata) {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_nodata) {
        return 0;
    }
    
    if (_haveJobSetting) {
        return 5;
    }
    else
    {
        return 1;
    }
}

- (NSString *)makeJobIntentStr
{
    NSString *jobIntentStr = @"";
    NSArray *jobIntentArr = [self.myjobSetting objectForKey:@"intent"];
    if ([jobIntentArr isKindOfClass:[NSArray class]] && (jobIntentArr.count > 0)) {
        for (int i = 0; i < jobIntentArr.count; i++) {
            NSDictionary *jobIntentItem = jobIntentArr[i];
            if (i == 0) {
                jobIntentStr = [jobIntentItem objectForKey:@"name"];
            }
            else
            {
                jobIntentStr = [NSString stringWithFormat:@"%@、%@", jobIntentStr, [jobIntentItem objectForKey:@"name"]];
            }
        }
    }
    return jobIntentStr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (_haveJobSetting) {
        switch (indexPath.row) {
            case 0:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Title1Identifier" forIndexPath:indexPath];
            }
                break;
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"BasicinfoIdentifier" forIndexPath:indexPath];
                
                UILabel *lblName = (UILabel *)[cell viewWithTag:1];
                UILabel *lblSex = (UILabel *)[cell viewWithTag:2];
                UILabel *lblBirthday = (UILabel *)[cell viewWithTag:3];
                UILabel *lblSchool = (UILabel *)[cell viewWithTag:4];
                UILabel *lblPhone = (UILabel *)[cell viewWithTag:5];
                UILabel *lblQQ = (UILabel *)[cell viewWithTag:6];
                
                lblName.text = [AppUtils readAPIField:self.myjobSetting key:@"name"];
                lblSex.text = [AppUtils readAPIField:self.myjobSetting key:@"sex"];
                lblBirthday.text = [[AppUtils readAPIField:self.myjobSetting key:@"birthday"] stringByReplacingOccurrencesOfString:@"|" withString:@"-"];
                lblSchool.text = [AppUtils readAPIField:self.myjobSetting key:@"school_name"];
                lblPhone.text = [AppUtils readAPIField:self.myjobSetting key:@"phone"];
                lblQQ.text = [AppUtils readAPIField:self.myjobSetting key:@"qq"];
            }
                break;
            case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
            }
                break;
            case 3:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Title2Identifier" forIndexPath:indexPath];
            }
                break;
            case 4:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"JobSettingIdentifier" forIndexPath:indexPath];
                
                UILabel *lblJobTime = (UILabel *)[cell viewWithTag:1];
                UILabel *lblJobIntent = (UILabel *)[cell viewWithTag:2];
                
                NSString *jobTimeStr = @"";
                NSArray *jobTimeArr = [self.myjobSetting objectForKey:@"job_time"];
                
                if ([jobTimeArr isKindOfClass:[NSArray class]] && (jobTimeArr.count > 0)) {
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                    
                    NSArray *sortedJobTimeArr = [jobTimeArr sortedArrayUsingDescriptors:sortDescriptors];
                    for (int i = 0; i < sortedJobTimeArr.count; i++) {
                        NSDictionary *jobTimeItem = sortedJobTimeArr[i];
                        if (i == 0) {
                            jobTimeStr = [jobTimeItem objectForKey:@"name"];
                        }
                        else
                        {
                            jobTimeStr = [NSString stringWithFormat:@"%@、%@", jobTimeStr, [jobTimeItem objectForKey:@"name"]];
                        }
                    }
                }
                lblJobTime.text = jobTimeStr;
                
                lblJobIntent.text = [self makeJobIntentStr];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddSettingIdentifier" forIndexPath:indexPath];
    }

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self]; 
}

- (IBAction)doModifySetting:(id)sender {
    //TODO JZ 修改简历
    ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
    vc.isSkip = NO;
    vc.theViewClass = [JobSettingViewController class];
    [AppUtils pushPage:self targetVC:vc];
}
@end
