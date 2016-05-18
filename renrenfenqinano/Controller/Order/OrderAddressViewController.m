//
//  OrderAddressViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-17.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderAddressViewController.h"
#import "AppUtils.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "OrderAddressAddViewController.h"
#import "OrderOKViewController.h"
#import "MobClick.h"

#define TAG @"OrderAddress"

#define TAG_CELL_IMAGE 1
#define TAG_CELL_INFO 2


@interface OrderAddressViewController ()
{
    NSDictionary *_accountInfo;
    NSMutableDictionary *_address;
    
    NSArray *_titleArr;
    NSMutableDictionary *_modelDict;
    NSArray *_keyArr;
    
    BOOL _hasAddress;
    BOOL _nodata;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation OrderAddressViewController

- (void)submitOrder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/vnd.int.{%@}+json", API_INT_VERSION] forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    //TODO
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSEnumerator *enumerator = [self.orderParams keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        /* code that uses the returned key */
        [parameters setObject:[self.orderParams objectForKey:key] forKey:key];
    }
    [parameters setObject:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"] forKey:@"uid"];
    [parameters setObject:[_accountInfo objectForKey:@"token"] forKey:@"token"];
    [parameters setObject:self.redPacketID forKey:@"red_id"];
    [parameters setObject:@"2" forKey:@"client_type"];
    
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_INT, SUBMIT_ORDER];
    [manager POST:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if (![jsonData objectForKey:@"status"]) {
            [AppUtils showSuccess:@"您已成功提交！"];
            
            NSDictionary *dict = @{@"product_id":self.goodsID};
            [MobClick event:@"buy_ok" attributes:dict];
            
            OrderOKViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderOKIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
            
            NSDictionary *dict = @{@"type" : [NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]};
            [MobClick event:@"buy_fail" attributes:dict];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getUserAddressFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/vnd.int.{%@}+json", API_INT_VERSION] forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid": [[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token": [_accountInfo objectForKey:@"token"],
                                 @"client": @"ios"
                                 };
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_INT, GET_ADDRESS];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        _nodata = NO;
        
        if (![jsonData objectForKey:@"status"]) {
            _hasAddress = YES;
            _address = [jsonData objectForKey:@"data"];
            [_modelDict setValue:[_address valueForKey:@"name"] forKey:@"name"];
            [_modelDict setValue:[_address valueForKey:@"phone"] forKey:@"phone"];
            [_modelDict setValue:[_address valueForKey:@"identity"] forKey:@"idcard"];
            [_modelDict setValue:[_address valueForKey:@"dorm_address"] forKey:@"school"];
        } else {
            _hasAddress = NO;
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
        [self.addressList reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _accountInfo = [AppUtils getUserInfo];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _address = [NSMutableDictionary dictionary];
    _nodata = YES;
    
    if (self.isSubmitHidden) {
        self.btnSubmit.hidden = YES;
    }
    
    _modelDict = [NSMutableDictionary dictionary];
    [_modelDict setValue:@"" forKey:@"name"];
    [_modelDict setValue:@"" forKey:@"idcard"];
    [_modelDict setValue:@"" forKey:@"phone"];
    [_modelDict setValue:@"" forKey:@"school"];
    _titleArr = @[@"", @"姓    名：", @"身份证：", @"手机号：", @"学    校："];
    _keyArr = @[@"", @"name", @"idcard", @"phone", @"school"];
    
    self.addressList.delegate = self;
    self.addressList.dataSource = self;
    self.addressList.scrollEnabled = NO;
    self.addressList.tableFooterView = [[UIView alloc] init];
//    [self.addressList.layer setBorderColor:[[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0] CGColor]];
//    [self.addressList.layer setBorderWidth:1.0];
    if ([self.addressList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.addressList setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.addressList respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.addressList setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:TAG];
    
    [self getUserAddressFromAPI];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:TAG];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.backgroundColor = [UIColor clearColor];
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
    
    if (!_hasAddress) {
        OrderAddressAddViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderAddressAddIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }

}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_nodata) {
        return 0;
    }
    
    if (_hasAddress) {
        return 5;
    }
    else
    {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (_hasAddress) {
        
        switch (indexPath.row) {
            case 0:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TipIdentifier" forIndexPath:indexPath];
            }
                break;
            case 1:
            case 2:
            case 3:
            case 4:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddressIdentifier" forIndexPath:indexPath];
                
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
                UILabel *lblValue = (UILabel *)[cell viewWithTag:2];
                
                lblTitle.text = _titleArr[indexPath.row];
                lblValue.text = [_modelDict valueForKey:_keyArr[indexPath.row]];

            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddAddressIdentifier" forIndexPath:indexPath];
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

- (IBAction)doSubmitAction:(id)sender {
    if (!_hasAddress) {
        [AppUtils showInfo:@"请先添加地址"];
        return;
    }
    
    [self submitOrder];
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}
@end
