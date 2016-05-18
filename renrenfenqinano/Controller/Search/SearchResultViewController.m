//
//  SearchResultViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-8.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "SearchResultViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "GoodsDetailViewController.h"
#import "AppDelegate.h"
#import "WishViewController.h"
#import "GoodsDetailSpecViewController.h"
#import "OrderWebViewController.h"

#define TAG_GOODS_IMAGE 1
#define TAG_GOODS_NAME 2
#define TAG_MONTH_PAYMENT 3
#define TAG_GOODS_PRICE 4


@interface SearchResultViewController ()
{
    int _pageNum;
    int _pageTotal;
    
    float _viewWidth;
    float _viewHeight;
    
    NSMutableArray *_goodsArr;
    UIStoryboard *_secondStorybord;
}

@end

@implementation SearchResultViewController

- (void)showNoResult
{
    self.tableResult.hidden = YES;

}

- (void)handleGoodsData:(NSDictionary *)result
{
    float tempTotal = [[result objectForKey:@"total"] floatValue] / [[result objectForKey:@"per_page"] intValue];
    _pageTotal = [[NSString stringWithFormat:@"%0.f", ceil(tempTotal)] intValue];
    
    if (_pageNum == 1) {
        _goodsArr = [[result objectForKey:@"list"] mutableCopy];
    }
    if (_pageNum > 1) {
        NSArray *tempArr = [result objectForKey:@"list"];
        [_goodsArr addObjectsFromArray:tempArr];
    }
    
    [self.tableResult reloadData];
    
    if ([[result objectForKey:@"total"] intValue] == 0)
    {
        [self showNoResult];
    }
}

- (void)searchGoodsListFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", _pageNum],
                                 @"keyword":self.keyword};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, SEARCH];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleGoodsData:[jsonData objectForKey:@"data"]];
        }
        else if ([@"500" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]])
        {
            [self showNoResult];
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
    
    _secondStorybord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, 63.0, _viewWidth, 0.5)];
    line.backgroundColor = GENERAL_COLOR_GRAY;
    [self.view addSubview:line];
    
    self.tableResult.dataSource = self;
    self.tableResult.delegate = self;
    self.tableResult.tableFooterView = [UIView new];
    if ([self.tableResult respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableResult setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableResult respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableResult setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.lblTitle.text = self.keyword;
    
    _goodsArr = [NSMutableArray array];
    _pageNum = 1;
    _pageTotal = 1;
    
    [self searchGoodsListFromAPI];
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

    OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
    vc.goodsID = [_goodsArr[indexPath.row] objectForKey:@"goods"];
    [AppUtils pushPage:self targetVC:vc];
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _goodsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    UIImageView *cellGoodsImg = (UIImageView *)[cell viewWithTag:TAG_GOODS_IMAGE];
    UILabel *cellGoodsName = (UILabel *)[cell viewWithTag:TAG_GOODS_NAME];
    UILabel *cellMonthPayment = (UILabel *)[cell viewWithTag:TAG_MONTH_PAYMENT];
    UILabel *cellGoodsPrice = (UILabel *)[cell viewWithTag:TAG_GOODS_PRICE];
    
    NSDictionary *theGoods = [_goodsArr objectAtIndex:indexPath.row];
    
    [cellGoodsImg.layer setMasksToBounds:YES];
    [cellGoodsImg.layer setBorderColor:[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [cellGoodsImg.layer setBorderWidth:0.5];
    [cellGoodsImg.layer setCornerRadius:2];
    [cellGoodsImg sd_setImageWithURL:[NSURL URLWithString:[theGoods objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    cellGoodsName.text = [theGoods objectForKey:@"name"];
    cellMonthPayment.text = [NSString stringWithFormat:@"月供：¥%.0f", [[theGoods objectForKey:@"month_price"] floatValue]];
    cellGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%.0f", [[theGoods objectForKey:@"price"] floatValue]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cellMonthPayment.text];
    NSString *tmpMonthPayment = [NSString stringWithFormat:@"¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:GENERAL_COLOR_RED
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:GENERAL_FONT18
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    cellMonthPayment.attributedText = attributedString;
    
    if (indexPath.row == _goodsArr.count - 1) {
        if (_pageNum < _pageTotal) {
            _pageNum++;
            [self searchGoodsListFromAPI];
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doGoWishAction:(id)sender {
    WishViewController *vc = [_secondStorybord instantiateViewControllerWithIdentifier:@"WishIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}
@end
