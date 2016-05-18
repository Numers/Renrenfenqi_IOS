//
//  OrderAddressAddViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-17.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderAddressAddViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#define NO_POS 0
#define POS_PROVINCE 1
#define POS_CITY 2
#define POS_RECT 3
#define POS_SCHOOL 4

@interface OrderAddressAddViewController ()
{
    int _curPos;
    NSMutableDictionary *_addressInfo;
    NSMutableDictionary *_schoolInfo;
    
    NSDictionary *_accountInfo;
    NSDictionary *_address;
    
    NSArray *_titleArr;
    NSArray *_keyArr;
    
    NSMutableDictionary *_modelDict;
}

@end

@implementation OrderAddressAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
    
    _modelDict = [NSMutableDictionary dictionary];
    [_modelDict setValue:@"" forKey:@"name"];
    [_modelDict setValue:@"" forKey:@"id"];
    [_modelDict setValue:@"" forKey:@"mobile"];
    [_modelDict setValue:@"" forKey:@"province"];
    [_modelDict setValue:@"" forKey:@"province_id"];
    [_modelDict setValue:@"" forKey:@"city"];
    [_modelDict setValue:@"" forKey:@"city_id"];
    [_modelDict setValue:@"" forKey:@"district"];
    [_modelDict setValue:@"" forKey:@"district_id"];
    [_modelDict setValue:@"" forKey:@"school"];
    [_modelDict setValue:@"" forKey:@"school_id"];
    [_modelDict setValue:@"" forKey:@"dorm"];
    
    _titleArr = @[@"姓      名：", @"身份证号：", @"手机号码：", @"所在省份：", @"所在城市：", @"所在地区：", @"所在学校：", @"宿舍地址："];
    _keyArr = @[@"name", @"id", @"mobile", @"province", @"city", @"district", @"school", @"dorm"];
    
    _accountInfo = [AppUtils getUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AddressSelectVCDelegate
- (void)AddressSelectVCDidDismisWithData:(NSObject *)data
{
    if (data) {
        if (_curPos == POS_PROVINCE) {
            if (![[data valueForKey:@"region_id"] isEqualToString:[_modelDict valueForKey:@"province_id"]]) {
                [_modelDict setValue:@"" forKey:@"city_id"];
                [_modelDict setValue:@"" forKey:@"city"];
                
                [_modelDict setValue:@"" forKey:@"district_id"];
                [_modelDict setValue:@"" forKey:@"district"];
                
                [_modelDict setValue:@"" forKey:@"school_id"];
                [_modelDict setValue:@"" forKey:@"school"];
            }
            
            [_modelDict setValue:[data valueForKey:@"region_id"] forKey:@"province_id"];
            [_modelDict setValue:[data valueForKey:@"region_name"] forKey:@"province"];
        } else if (_curPos == POS_CITY) {
            if (![[data valueForKey:@"region_id"] isEqualToString:[_modelDict valueForKey:@"city_id"]]) {
                [_modelDict setValue:@"" forKey:@"district_id"];
                [_modelDict setValue:@"" forKey:@"district"];
                
                [_modelDict setValue:@"" forKey:@"school_id"];
                [_modelDict setValue:@"" forKey:@"school"];
            }
            
            [_modelDict setValue:[data valueForKey:@"region_id"] forKey:@"city_id"];
            [_modelDict setValue:[data valueForKey:@"region_name"] forKey:@"city"];
        } else if (_curPos == POS_RECT) {
            if (![[data valueForKey:@"region_id"] isEqualToString:[_modelDict valueForKey:@"district_id"]]) {
                [_modelDict setValue:@"" forKey:@"school_id"];
                [_modelDict setValue:@"" forKey:@"school"];
            }
            
            [_modelDict setValue:[data valueForKey:@"region_id"] forKey:@"district_id"];
            [_modelDict setValue:[data valueForKey:@"region_name"] forKey:@"district"];
        } else if (_curPos == POS_SCHOOL) {
            [_modelDict setValue:[data valueForKey:@"school_id"] forKey:@"school_id"];
            [_modelDict setValue:[data valueForKey:@"school_name"] forKey:@"school"];
        }
        
        [self.tableList reloadData];
    }
    
    MyLog(@"data = %@", data);
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3) {
        _curPos = POS_PROVINCE;
        AddressSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressSelectIdentifier"];
        vc.params = @{@"parent_id":@""};
        vc.type = TYPE_AREA;
        vc.delegate = self;
        [AppUtils pushPage:self targetVC:vc];
    } else if (indexPath.row == 4) {
        if (![AppUtils isNullStr:[_modelDict valueForKey:@"province_id"]]) {
            _curPos = POS_CITY;
            AddressSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressSelectIdentifier"];
            vc.params = @{@"parent_id":[_modelDict valueForKey:@"province_id"]};
            vc.type = TYPE_AREA;
            vc.delegate = self;
            [AppUtils pushPage:self targetVC:vc];
        } else {
            [AppUtils showInfo:@"请先选择省份"];
        }
    } else if (indexPath.row == 5) {
        if (![AppUtils isNullStr:[_modelDict valueForKey:@"city_id"]]) {
            _curPos = POS_RECT;
            AddressSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressSelectIdentifier"];
            vc.params = @{@"parent_id":[_modelDict valueForKey:@"city_id"]};
            vc.type = TYPE_AREA;
            vc.delegate = self;
            [AppUtils pushPage:self targetVC:vc];
        } else {
            [AppUtils showInfo:@"请先选择城市"];
        }
    } else if (indexPath.row == 6) {
        if (![AppUtils isNullStr:[_modelDict valueForKey:@"district_id"]]) {
            _curPos = POS_SCHOOL;
            AddressSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressSelectIdentifier"];
            vc.params = @{@"province_id":[_modelDict valueForKey:@"province_id"], @"city_id":[_modelDict valueForKey:@"city_id"], @"district_id":[_modelDict valueForKey:@"district_id"]};
            vc.type = TYPE_SCHOOL;
            vc.delegate = self;
            [AppUtils pushPage:self targetVC:vc];
        } else {
            [AppUtils showInfo:@"请先选择城区"];
        }
    }
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 8) {
        return 160;
    }
    
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 7) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"TextIdentifier" forIndexPath:indexPath];
        
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
        UITextField *txtValue = (UITextField *)[cell viewWithTag:2];
        txtValue.delegate = self;
        txtValue.returnKeyType = UIReturnKeyDone;
        
        lblTitle.text = _titleArr[indexPath.row];
        txtValue.text = _modelDict[_keyArr[indexPath.row]];
        
    } else if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6) {
        cell= [tableView dequeueReusableCellWithIdentifier:@"SelectIdentifier" forIndexPath:indexPath];
        
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
        UILabel *lblValue = (UILabel *)[cell viewWithTag:2];
        
        lblTitle.text = _titleArr[indexPath.row];
        lblValue.text = _modelDict[_keyArr[indexPath.row]];
    } else {
        cell= [tableView dequeueReusableCellWithIdentifier:@"ButtonIdentifier" forIndexPath:indexPath];
        
        UIButton *btn = (UIButton *)[cell viewWithTag:1];
        [btn addTarget:self action:@selector(doSaveAddress) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void) doSaveAddress {
    UITableViewCell *cell = [self.tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *txtName = (UITextField *)[cell viewWithTag:2];
    NSString *theName = [AppUtils trimWhite:txtName.text];
    if (theName.length < 2) {
        [AppUtils showInfo:@"请输入姓名"];
        return;
    }
    
    cell = [self.tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UITextField *txtPhone = (UITextField *)[cell viewWithTag:2];
    NSString *thePhone = [AppUtils trimWhite:txtPhone.text];
    if (thePhone.length <= 0) {
        [AppUtils showInfo:@"手机号码不能为空"];
        return;
    }
    if (![AppUtils isMobileNumber:thePhone]) {
        [AppUtils showInfo:@"手机号码格式不正确"];
        return;
    }
    
    cell = [self.tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *txtIDCard = (UITextField *)[cell viewWithTag:2];
    NSString *theIDCard = [[AppUtils trimWhite:txtIDCard.text] uppercaseString];
    if ([AppUtils isNullStr:theIDCard]) {
        [AppUtils showInfo:@"身份证号码不能为空"];
        return;
    }
    if (![AppUtils isIDCardNumber:theIDCard]) {
        [AppUtils showInfo:@"身份证号码格式不正确"];
        return;
    }
    
    cell = [self.tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    UILabel *lblSchool = (UILabel *)[cell viewWithTag:2];
    NSString *theSchool = [AppUtils trimWhite:lblSchool.text];
    if (theSchool.length < 2) {
        [AppUtils showInfo:@"请选择学校"];
        return;
    }
    
    cell = [self.tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    UITextField *txtDorm = (UITextField *)[cell viewWithTag:2];
    NSString *theDorm = [AppUtils trimWhite:txtDorm.text];
    if (theDorm.length < 2) {
        [AppUtils showInfo:@"请输入正确的宿舍地址"];
        return;
    }
    
    //TODO submit
    [self submitToSaveAddress:@{@"name":theName, @"phone":thePhone, @"dorm":theDorm, @"school_id":[_modelDict valueForKey:@"school_id"], @"idcard":theIDCard}];
}

- (void)submitToSaveAddress:(NSDictionary *)params {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/vnd.int.{%@}+json", API_INT_VERSION] forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"],
                                 @"client":@"ios",
                                 @"name":[params valueForKey:@"name"],
                                 @"phone":[params valueForKey:@"phone"],
                                 @"dorm_address":[params valueForKey:@"dorm"],
                                 @"school_id":[params valueForKey:@"school_id"],
                                 @"identity":[params valueForKey:@"idcard"]};
    
    //    MyLog(parameters.description);
    
    [manager POST:[NSString stringWithFormat:@"%@%@", API_INT, ADD_ADDRESS] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if (![jsonData objectForKey:@"status"]) {
            [AppUtils showSuccess:@"您已成功提交！"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_AUTH_INFO object:self];
            
            [self doBackAction:nil];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
    
    [self.tableList scrollToRowAtIndexPath:[self.tableList indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;

    NSIndexPath *indexPath = [self.tableList indexPathForCell:cell];
    [_modelDict setValue:textField.text forKey:_keyArr[indexPath.row]];
}


- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}
@end
