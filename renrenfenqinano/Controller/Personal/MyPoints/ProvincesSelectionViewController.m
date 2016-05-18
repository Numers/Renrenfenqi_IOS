//
//  ProvincesSelectionViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/1.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "ProvincesSelectionViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"

#import "AuthenticationViewController.h"
#import "ImprovePersonalInfoViewController.h"

@interface ProvincesSelectionViewController ()

@end

static NSString *cellIdentifiler = @"Cell";

@implementation ProvincesSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    
    [self.contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.contentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.contentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.contentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.contentTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据处理
- (void)getProvincesFromAPI:(NSString *)parentId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"parent_id": parentId};
    
    [AppUtils showLoadIng:@""];
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, GET_PROVINECES] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            [self handleProvincesData:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleProvincesData:(NSDictionary *)data
{
    NSMutableArray *tempArr = [[data objectForKey:@"data"] mutableCopy];
    if (tempArr.count == 0) {
        NSLog(@"提交地区选择");
        // 将选择的省市区数据返回到需要界面 消息发送
        NSDictionary *tempDic = [NSDictionary dictionaryWithObject:self.locationArr forKey:LOCTION_KEY];
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_SCHOLL_LIST object:nil userInfo:tempDic];
        
        
//        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//        
//        int count = (int)viewControllers.count;
//        while (count-- ) {
//            UIViewController *vc = [viewControllers objectAtIndex:count];
//            if ([vc isKindOfClass:[ProvincesSelectionViewController class]]) {
//            }else{
//                [AppUtils popToPage:self targetVC:vc];
//            }
//        }
        
        
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ImprovePersonalInfoViewController class]]) {
                [AppUtils popToPage:self targetVC:controller];
            }else if ([controller isKindOfClass:[AuthenticationViewController class]]) {
                [AppUtils popToPage:self targetVC:controller];
            }
        }
        
    }else{
        ProvincesSelectionViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"ProvincesSelectionIdentifier"];
        vc.dataArr = tempArr;
        vc.locationArr = self.locationArr;
        [AppUtils pushPage:self targetVC:vc];
    }
}


#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    
    if (self.dataArr.count <= indexPath.row) {
        return cell;
    }
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:10];
    if (nil == contentLabel) {
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.frame.size.width - 30, 44)];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.font = GENERAL_FONT13;
        contentLabel.textColor = UIColorFromRGB(0x000000);;
        contentLabel.numberOfLines = 1;
        contentLabel.tag = 10;
        [cell addSubview:contentLabel];
    }
    
    contentLabel.text = [self.dataArr[indexPath.row] objectForKey:@"region_name"];
    
    return cell;
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    
    if (self.dataArr.count <= indexPath.row) {
        return;
    }
    
    if (self.locationArr == nil) {
        self.locationArr = [NSMutableArray array];
    }
    // 保持省市区的添加
    [self.locationArr addObject:[self.dataArr objectAtIndex:indexPath.row]];
    [self getProvincesFromAPI:[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"region_id"]];
}

#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
