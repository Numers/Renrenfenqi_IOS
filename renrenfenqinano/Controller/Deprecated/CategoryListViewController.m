//
//  CategoryListViewController.m
//  renrenfenqinano
//
//  Created by coco on 14-11-12.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "CategoryListViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "GoodsDetailViewController.h"
#import "GoodsDetailSpecViewController.h"
#import "OrderWebViewController.h"

#define TAG @"CategoryList"

/**
    原商品列表页，需要废弃
 */

@interface CategoryListViewController ()
{
    float _viewWidth;
    float _viewHeight;
    
    int _pageNum;
    int _pageTotal;
    
    NSString *_keyName;
    
    NSMutableArray *_goodsArr;
}

@end

@implementation CategoryListViewController

- (void)back
{
    [AppUtils goBack:self];
}

- (void)handleGoodsData:(NSDictionary *)result
{
    float tempTotal = [[result objectForKey:@"total"] floatValue] / [[result objectForKey:@"per_page"] intValue];
    _pageTotal = [[NSString stringWithFormat:@"%0.f", ceil(tempTotal)] intValue];
    
    if (_pageNum == 1) {
            _goodsArr = [[result objectForKey:@"list"] mutableCopy];
    }
    if (_pageNum > 1) {
        NSArray *ordersArr = [result objectForKey:@"list"];
        [_goodsArr addObjectsFromArray:ordersArr];
    }
    
    self.lblTitle.text = [result objectForKey:_keyName];
    
    [self.goodsList reloadData];
}

- (void)getGoodsListFromAPI
{
    //TODO
    if ([self.type isEqualToString:@"category"]) {
        _keyName = @"cat_name";
        [self getGoodsListByCategoryFromAPI];
    }
    else if ([self.type isEqualToString:@"brand"])
    {
        _keyName = @"brand_name";
        [self getGoodsListByBrandFromAPI];
    }
}

- (void)getGoodsListByCategoryFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", _pageNum]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, CATEGORY_LIST] stringByReplacingOccurrencesOfString:@"{cname}" withString:self.categoryName];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleGoodsData:[jsonData objectForKey:@"data"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getGoodsListByBrandFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", _pageNum]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, BRAND_LIST] stringByReplacingOccurrencesOfString:@"{brandid}" withString:self.brandID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        //        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleGoodsData:[jsonData objectForKey:@"data"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    float theWidth = _viewWidth;
    float theTop = 64.0;
    UIView *line = [AppUtils makeLine:theWidth theTop:theTop];
    [self.view addSubview:line];
    
    self.goodsList.delegate = self;
    self.goodsList.dataSource = self;
    self.goodsList.tableFooterView = [UIView new];
    if ([self.goodsList respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.goodsList setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.goodsList respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.goodsList setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _goodsArr = [NSMutableArray array];
    _pageNum = 1;
    _pageTotal = 1;
    
    [self getGoodsListFromAPI];
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
    cell.textLabel.font = GENERAL_FONT15;
    
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
    
    OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
    vc.goodsID = [_goodsArr[indexPath.row] objectForKey:@"goods"];
    [AppUtils pushPage:self targetVC:vc];
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _goodsArr.count;
}

- (NSString *)makeImageUrl:(NSString *)imagePath
{
    return [NSString stringWithFormat:@"%@%@", IMAGE_BASE, imagePath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    NSDictionary *theGoods = _goodsArr[indexPath.row];
    
    UIImageView *imgGoods = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 10.0, 50.0, 50.0)];
    [imgGoods sd_setImageWithURL:[NSURL URLWithString:[theGoods objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    [cell addSubview:imgGoods];
    
    UILabel *lblGoodsName = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 10.0, _viewWidth - 90.0, 35.0)];
    lblGoodsName.font = GENERAL_FONT13;
    lblGoodsName.text = [theGoods objectForKey:@"name"];
    lblGoodsName.numberOfLines = 2;
    [cell addSubview:lblGoodsName];
    
    UILabel *lblMonthPaymentTitle = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 45.0, 45.0, 15.0)];
    lblMonthPaymentTitle.font = GENERAL_FONT13;
    lblMonthPaymentTitle.text = @"月供：";
    [cell addSubview:lblMonthPaymentTitle];
    
    UILabel *lblMonthPayment = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 45.0, 55.0, 15.0)];
    lblMonthPayment.font = GENERAL_FONT13;
    lblMonthPayment.textColor = [UIColor colorWithRed:231/255.0 green:88/255.0 blue:69/255.0 alpha:1.0];
    lblMonthPayment.text = [NSString stringWithFormat:@"¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    [cell addSubview:lblMonthPayment];
    
    UILabel *lblGoodsPrice = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 115.0, 45.0, 100.0, 15.0)];
    lblGoodsPrice.font = GENERAL_FONT13;
    lblGoodsPrice.textColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0];
    lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.f", [[theGoods objectForKey:@"price"] floatValue]];
    [cell addSubview:lblGoodsPrice];
    
    if (indexPath.row == _goodsArr.count - 1) {
        if (_pageNum < _pageTotal) {
            _pageNum++;
            [self getGoodsListFromAPI];
        }
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

- (IBAction)backAction:(id)sender {
    [self back];
}
@end
