//
//  GoodsRatesViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-9.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "GoodsRatesViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#define TAG_RATE_COUNT 1
#define TAG_RATE_STAR 1
#define TAG_RATE_NAME 2
#define TAG_RATE_CONTENT 3

@interface GoodsRatesViewController ()
{
    int _pageNum;
    int _pageTotal;
    
    float _viewWidth;
    float _viewHeight;
    
    NSMutableArray *_ratesArr;
    int _rateTotal;
}

@end

@implementation GoodsRatesViewController

- (void)handleGoodsData:(NSDictionary *)result
{
    float tempTotal = [[result objectForKey:@"total"] floatValue] / [[result objectForKey:@"per_page"] intValue];
    _pageTotal = [[NSString stringWithFormat:@"%0.f", ceil(tempTotal)] intValue];
    _rateTotal = [[result objectForKey:@"total"] floatValue];
    
    if (_pageNum == 1) {
        _ratesArr = [[result objectForKey:@"list"] mutableCopy];
    }
    if (_pageNum > 1) {
        NSArray *tempArr = [result objectForKey:@"list"];
        [_ratesArr addObjectsFromArray:tempArr];
    }
    
    [self.tableRates reloadData];
}

- (void)getGoodsRatesFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", _pageNum]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, RATELIST] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleGoodsData:[jsonData objectForKey:@"data"]];
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
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    UIView *line = [AppUtils makeLine:_viewWidth theTop:64.0];
    [self.view addSubview:line];
    
    _ratesArr = [NSMutableArray array];
    _pageNum = 1;
    _pageTotal = 1;
    
    self.tableRates.dataSource = self;
    self.tableRates.delegate = self;
    self.tableRates.tableFooterView = [UIView new];
    if ([self.tableRates respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableRates setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableRates respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableRates setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self getGoodsRatesFromAPI];
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
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 44;
    
    if (indexPath.row == 0)
    {
        return 44.0;
    }
    else
    {
        CGSize maximumLabelSize = CGSizeMake(_viewWidth - 30.0, 2000.0);
        NSDictionary *theRate = [_ratesArr objectAtIndex:indexPath.row - 1];
        
        CGSize expectedLabelSize = [[theRate objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:13.0]
                                                                 constrainedToSize:maximumLabelSize
                                                                     lineBreakMode:NSLineBreakByWordWrapping];
        
        MyLog(@"%0.f", expectedLabelSize.height);
        return 23.0 + MAX(expectedLabelSize.height, 21.0);
    }
    
//    if (indexPath.row > 1) {
//        CGSize maximumLabelSize = CGSizeMake(_viewWidth - 30.0, 2000.0);
//        NSDictionary *theRate = [_ratesArr objectAtIndex:indexPath.row - 1];
//        
//        CGSize expectedLabelSize = [[theRate objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:13.0]
//                                                                 constrainedToSize:maximumLabelSize
//                                                                     lineBreakMode:NSLineBreakByWordWrapping];
//        
//        MyLog(@"%0.f", expectedLabelSize.height);
//        return 23.0 + MAX(expectedLabelSize.height, 21.0);
//    }
//    else
//    {
//        return 44.0;
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _ratesArr.count + 1;
}

- (NSString *)makeStarStr:(int)starValue
{
    NSString *starStr = @"";
    
    switch (starValue) {
        case 2:
        {
            starStr = @"orderevaluation_body_star01_h";
        }
            break;
        case 4:
        {
            starStr = @"orderevaluation_body_star02_h";
        }
            break;
        case 6:
        {
            starStr = @"orderevaluation_body_star03_h";
        }
            break;
        case 8:
        {
            starStr = @"orderevaluation_body_star04_h";
        }
            break;
        case 10:
        {
            starStr = @"orderevaluation_body_star05_h";
        }
            break;
            
        default:
            break;
    }
    
    return starStr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RateTitleIdentifier" forIndexPath:indexPath];
        
        UILabel *cellCount = (UILabel *)[cell viewWithTag:TAG_RATE_COUNT];
        cellCount.text = [NSString stringWithFormat:@"评价晒单(%d人评价)", _rateTotal];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RateContentIdentifier" forIndexPath:indexPath];
        
        NSDictionary *theRate = [_ratesArr objectAtIndex:indexPath.row - 1];
        
        UIImageView *cellRateStar = (UIImageView *)[cell viewWithTag:TAG_RATE_STAR];
        UILabel *cellName = (UILabel *)[cell viewWithTag:TAG_RATE_NAME];
        UILabel *cellContent = (UILabel *)[cell viewWithTag:TAG_RATE_CONTENT];
        
        NSString *starName = [self makeStarStr:[[theRate objectForKey:@"star"] intValue]];
        [cellRateStar setImage:[UIImage imageNamed:starName]];
        cellName.text = [NSString stringWithFormat:@"%@  %@", [theRate objectForKey:@"person"], [theRate objectForKey:@"time"]];
        cellContent.text = [theRate objectForKey:@"content"];
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
