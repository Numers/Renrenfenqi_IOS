//
//  JobDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-24.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "JobDetailViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UserLoginViewController.h"
#import "ImprovePersonalInfoViewController.h"
#import "ImprovePersonalInfoViewController2.h"

@interface JobDetailViewController ()
{
    NSMutableDictionary *_jobDetail;
    NSMutableDictionary *_myjobSetting;
    UIWebView *_webview;
    NSDictionary *_accountInfo;
    
    float _viewWidth;
    float _viewHeight;
    
    float _jobDescHeight;
    BOOL _isLoaded;
    
    UIStoryboard *_secondStorybord;
}

@end

@implementation JobDetailViewController

- (NSString *)preHandleHtml:(NSString *)htmlStr
{
    //    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"style=\"\"" withString:@"style=\"width:100%;\""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p><br/></p>" withString:@""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"style=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"width=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"height=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<img " withString:@"<img style=\"width:100%;\""];
    
    return htmlStr;
}

- (void)getJobDetailFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"id":self.jobDeailId};
    [manager GET:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_JOBDETAIL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _jobDetail = [jsonData objectForKey:@"data"];
            [self.tableDetail reloadData];
            
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getMyJobSettingFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]};
//    NSDictionary *parameters = @{@"uid":@"5"};
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_MYJOB_SETTING] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//                MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _myjobSetting = [jsonData objectForKey:@"data"];
            if (![_myjobSetting objectForKey:@"state"]) {
                
                if ([[NSString stringWithFormat:@"%@", [_myjobSetting objectForKey:@"is_info"]] isEqualToString:@"0"]) {
                    //TODO JZ 去 完善资料 must
                    ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
                    vc.isSkip = NO;
                    vc.theViewClass = [JobDetailViewController class];
                    [AppUtils pushPage:self targetVC:vc];
                }
                else
                {
                    if (!([_myjobSetting objectForKey:@"intent"] || [_myjobSetting objectForKey:@"job_time"])) {
                        //有资料，但是没有填写兼职意向
                        //TODO JZ 去 填写兼职意向
                        ImprovePersonalInfoViewController2 *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
                        vc.theViewClass = [JobDetailViewController class];
                        [AppUtils pushPage:self targetVC:vc];
                    }
                }

                if ( ([[NSString stringWithFormat:@"%@", [_myjobSetting objectForKey:@"is_info"]] isEqualToString:@"1"]) &&
                    ([_myjobSetting objectForKey:@"intent"] || [_myjobSetting objectForKey:@"job_time"])
                    ) {
                    
                    [self submitToApplyJob];
                }
            }
            else if ([_myjobSetting objectForKey:@"state"] && ([[NSString stringWithFormat:@"%@", [_myjobSetting objectForKey:@"is_info"]] isEqualToString:@"1"]))
            {
                ImprovePersonalInfoViewController2 *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfo2Identifier"];
                vc.theViewClass = [JobDetailViewController class];
                [AppUtils pushPage:self targetVC:vc];
            }
            else
            {
                //TODO JZ 没设置 去 完善资料 must
                ImprovePersonalInfoViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"ImprovePersonalInfoIdentifier"];
                vc.isSkip = NO;
                vc.theViewClass = [JobDetailViewController class];
                [AppUtils pushPage:self targetVC:vc];
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

- (void)submitToApplyJob
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    //TODO JZ 增加paramter https://tower.im/projects/73ce0121f6784617aa3226f2051afd76/docs/5cfa4623bbd44ff7bf5c363da96f3dd1/
    NSDictionary *parameters = @{
                                 @"students_id":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"job_id":self.jobDeailId,
                                 @"title":[AppUtils readAPIField:_jobDetail key:@"title"],
                                 @"school":[AppUtils readAPIField:_myjobSetting key:@"school_name"],
                                 @"uname":[AppUtils readAPIField:_myjobSetting key:@"name"],
                                 @"mobile":[AppUtils readAPIField:_myjobSetting key:@"phone"]
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@", JOB_BASE, APPLY_JOB] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _jobDetail = [NSMutableDictionary dictionary];
    _myjobSetting = [NSMutableDictionary dictionary];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    UIView *theLine = [AppUtils makeLine:_viewWidth theTop:63.0];
    [self.view addSubview:theLine];
    
    UIView *theLine1 = [AppUtils makeLine:_viewWidth theTop:0.0];
    [self.btnView addSubview:theLine1];
    
    if (self.isHideJobApply) {
        self.btnView.hidden = YES;
    }
    
    self.tableDetail.delegate = self;
    self.tableDetail.dataSource = self;
    self.tableDetail.tableFooterView = [UIView new];
    self.tableDetail.backgroundColor = [UIColor clearColor];
    if ([self.tableDetail respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableDetail setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableDetail respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableDetail setLayoutMargins:UIEdgeInsetsZero];
    }

    [self getJobDetailFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _accountInfo = [AppUtils getUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 60;
    float height = 43;
    switch (indexPath.row) {
        case 0:
        {
            height = 60.0;
        }
            break;
        case 1:
        case 3:
        case 5:
        {
            height = 10.0;
        }
            break;
        case 2:
        {
            height = 175.0;
        }
            break;
        case 4:
        {
//            height = _jobDescHeight;
            height = _webview.frame.size.height + 60.0;
        }
            break;
            
        default:
            break;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    MyLog(@"job detail %d", (int)_jobDetail.count);
    if (_jobDetail.count) {
        return 8;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleIdentifier" forIndexPath:indexPath];
            UILabel *lblJobTitle = (UILabel *)[cell viewWithTag:1];
            UILabel *lblRect = (UILabel *)[cell viewWithTag:2];
            UILabel *lblCreateTime = (UILabel *)[cell viewWithTag:3];
            lblJobTitle.text = [_jobDetail objectForKey:@"title"];
            lblRect.text = [[_jobDetail objectForKey:@"region"] stringByReplacingOccurrencesOfString:@"/" withString:@" "];
            lblCreateTime.text = [[_jobDetail objectForKey:@"ctime"] substringToIndex:10];
        }
            break;
        case 1:
        case 3:
        case 5:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"JobInfoIdentifier" forIndexPath:indexPath];
            
            UILabel *lblJobType = (UILabel *)[cell viewWithTag:1];
            UILabel *lblJobPublisher = (UILabel *)[cell viewWithTag:2];
            UILabel *lblEmployeeNum = (UILabel *)[cell viewWithTag:3];
            UILabel *lblWage = (UILabel *)[cell viewWithTag:4];
            UILabel *lblRegion = (UILabel *)[cell viewWithTag:5];
            UILabel *lblWorkTime = (UILabel *)[cell viewWithTag:6];
            UILabel *lblSettlement = (UILabel *)[cell viewWithTag:7];
            
            lblJobType.text = [_jobDetail objectForKey:@"type"];
            lblJobPublisher.text = [_jobDetail objectForKey:@"bus_name"];
            lblEmployeeNum.text = [NSString stringWithFormat:@"%@人", [_jobDetail objectForKey:@"job_num"]];
            lblWage.text = [NSString stringWithFormat:@"%@", [_jobDetail objectForKey:@"wage"]];
            lblRegion.text = [[_jobDetail objectForKey:@"region"] stringByReplacingOccurrencesOfString:@"/" withString:@" "];
            lblWorkTime.text = [_jobDetail objectForKey:@"work_time"];
            lblSettlement.text = [_jobDetail objectForKey:@"settlement"];
        }
            break;
        case 4:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"JobDescIdentifier" forIndexPath:indexPath];
            
            _webview = [[UIWebView alloc] initWithFrame:CGRectMake(15.0, 30.0, _viewWidth - 30.0, 80.0)];
            _webview.scrollView.scrollEnabled = NO;
            _webview.scrollView.bounces = NO;
            _webview.delegate = self;
            _webview.scalesPageToFit = YES;
            NSString *str = [NSString stringWithFormat:@"<html><body style='font-size:36px'>%@</body></html>", [_jobDetail objectForKey:@"info"]];
            [_webview loadHTMLString:[self preHandleHtml:str] baseURL:nil];
            
            [cell addSubview:_webview];
            
        }
            break;
        case 6:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIdentifier" forIndexPath:indexPath];
            
            UILabel *lblContact = (UILabel *)[cell viewWithTag:1];
            lblContact.text = [NSString stringWithFormat:@"联系人：%@", [_jobDetail objectForKey:@"uname"]];
        }
            break;
        case 7:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TipIdentifier" forIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }

    
    return cell;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
        CGRect frame = webView.frame;
        frame.size.height = 1;
        webView.frame = frame;
        //Asks the view to calculate and return the size that best fits //its subviews.
        CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
        frame.size = fittingSize;
        webView.frame = frame;
        [self.tableDetail beginUpdates];
        [self.tableDetail endUpdates];

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

- (void)jobApply
{
    [self getMyJobSettingFromAPI];
}

- (IBAction)doJobApplyAction:(id)sender {
    if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
        UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        vc.writeInfoMode = WriteInfoModeMust;
        vc.parentClass = [JobDetailViewController class];
        [AppUtils pushPageFromBottomToTop:self targetVC:vc];
        return;
    }
    
    [self jobApply];
}
@end
