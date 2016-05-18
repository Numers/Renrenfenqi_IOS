//
//  AddressSelectViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "AddressSelectViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#define TAG_CELL_NAME 1
#define TAG_CELL_IMAGE 2

@interface AddressSelectViewController ()
{
    NSMutableArray *_dataArr;
    
    NSString *_provinceName;
    NSString *_cityName;
    NSString *_rectName;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation AddressSelectViewController

- (void)returnData:(NSDictionary *)data
{
    if(_delegate && [_delegate respondsToSelector:@selector(AddressSelectVCDidDismisWithData:)])
    {
        [_delegate AddressSelectVCDidDismisWithData:data];
    }
}

- (void)getSchoolFromAPI:(NSDictionary *)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/vnd.int.{%@}+json", API_INT_VERSION] forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = params;
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_INT, GET_SCHOOLS];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if (![jsonData objectForKey:@"status"]) {
            _dataArr = [jsonData objectForKey:@"data"];
            [self.tableAddress reloadData];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getAreaFromAPI:(NSDictionary *)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/vnd.int.{%@}+json", API_INT_VERSION] forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    MyLog(@"params = %@", params);
    
    NSDictionary *parameters = @{@"parent_id":[params valueForKey:@"parent_id"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", API_INT, GET_AREA];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if (![jsonData objectForKey:@"status"]) {
            _dataArr = [jsonData objectForKey:@"data"];
            [self.tableAddress reloadData];
        } else {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        MyLog(@"error = %@", error.description);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _dataArr = [NSMutableArray array];
    
    self.tableAddress.dataSource = self;
    self.tableAddress.delegate = self;
    
    if (self.type == TYPE_AREA) {
        [self getAreaFromAPI:self.params];
    } else {
        [self getSchoolFromAPI:self.params];
    }
    
    UIView *theLine = [AppUtils makeLine:_viewWidth theTop:64.0];
    [self.view addSubview:theLine];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *cellImage = (UIImageView *)[cell viewWithTag:TAG_CELL_IMAGE];
    [cellImage setImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_h"]];
    
    NSDictionary *theDict = [_dataArr objectAtIndex:indexPath.row];
    [self returnData:theDict];
    [self doBackAction:nil];
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
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    UILabel *cellName = (UILabel *)[cell viewWithTag:TAG_CELL_NAME];
    UIImageView *cellImage = (UIImageView *)[cell viewWithTag:TAG_CELL_IMAGE];
    [cellImage setImage:[UIImage imageNamed:@"automaticpaymentsset_body_choose_n"]];

    NSDictionary *theItem = [_dataArr objectAtIndex:indexPath.row];
    if (self.type == TYPE_AREA) {
        cellName.text = [theItem objectForKey:@"region_name"];
    } else {
        cellName.text = [theItem objectForKey:@"school_name"];
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
@end
