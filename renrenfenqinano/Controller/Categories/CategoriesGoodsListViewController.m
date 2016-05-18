//
//  CategoriesGoodsListViewController.m
//  renrenfenqi
//
//  Created by coco on 15-4-7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CategoriesGoodsListViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "GoodsDetailViewController.h"
#import "GoodsDetailSpecViewController.h"
#import "OrderWebViewController.h"
#import "GoodsItemCell.h"

@interface CategoriesGoodsListViewController ()
{
    float _viewWidth;
    float _viewHeight;
    
    float _cellWidth;
    float _cellHeight;
    
    enum ListType _listType;
    CGPoint _lastContentOffset;
    
    int _pageNum;
    int _pageTotal;
    
    NSString *_keyName;
    
    NSMutableArray *_goodsArr;
}

@end

@implementation CategoriesGoodsListViewController

- (void)handleGoodsData:(NSDictionary *)result
{
    float tempTotal = [[result objectForKey:@"total"] floatValue] / [[result objectForKey:@"per_page"] intValue];
    _pageTotal = [[NSString stringWithFormat:@"%0.f", ceil(tempTotal)] intValue];
    
    if (_pageNum == 1) {
        _goodsArr = [[result objectForKey:@"list"] mutableCopy];
//        if (_goodsArr.count <= 6) {
//            self.goodsListTable.bounces = NO;
//        }
    }
    if (_pageNum > 1) {
        NSArray *ordersArr = [result objectForKey:@"list"];
        [_goodsArr addObjectsFromArray:ordersArr];
    }
    
    self.lblTitle.text = [result objectForKey:_keyName];
    
    [self.goodsListTable reloadData];
    [self.goodsListCollection reloadData];
}

- (void)getGoodsListFromAPI
{
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
    float theTop = 63.5;
    UIView *line = [AppUtils makeLine:theWidth theTop:theTop];
    [self.view addSubview:line];
    
    _cellWidth = (self.view.bounds.size.width - 30) * 0.5;
    _cellHeight = _cellWidth * 43 / 30;
    
    _goodsArr = [NSMutableArray array];
    _pageNum = 1;
    _pageTotal = 1;
    
    _listType = ListTypeList;
    
//    self.goodsListTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 65.0 + 44.0, _viewWidth, _viewHeight - 64.0 - 44.0)];
//    self.goodsListTable.frame = CGRectMake(0.0, 65.0 + 44.0, _viewWidth, _viewHeight - 64.0 - 44.0);
//    self.goodsListCollection.frame = CGRectMake(0.0, 65.0, _viewWidth, _viewHeight - 64.0);
//    MyLog(@"viewheight = %0.0f", _viewHeight - 64.0 - 44.0);
    
    self.goodsListTable.delegate = self;
    self.goodsListTable.dataSource = self;
    self.goodsListTable.tableFooterView = [UIView new];
    if ([self.goodsListTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.goodsListTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.goodsListTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.goodsListTable setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.goodsListCollection.dataSource = self;
    self.goodsListCollection.delegate = self;
    self.goodsListCollection.hidden = YES;
    
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

- (NSString *)makeImageUrl:(NSString *)imagePath
{
    return [NSString stringWithFormat:@"%@%@", IMAGE_BASE, imagePath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *theGoods = _goodsArr[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    UIImageView *imgGoods = (UIImageView *)[cell viewWithTag:1];
    UILabel *lblGoodsName = (UILabel *)[cell viewWithTag:2];
    UILabel *lblMonthPayment = (UILabel *)[cell viewWithTag:3];
    UILabel *lblGoodsPrice = (UILabel *)[cell viewWithTag:4];
    
    [imgGoods.layer setMasksToBounds:YES];
    [imgGoods.layer setBorderColor:[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [imgGoods.layer setBorderWidth:0.5];
//    [imgGoods.layer setCornerRadius:2];
    [imgGoods sd_setImageWithURL:[NSURL URLWithString:[theGoods objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    lblGoodsName.text = [theGoods objectForKey:@"name"];
    lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.f", [[theGoods objectForKey:@"price"] floatValue]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lblMonthPayment.text];
    NSString *tmpMonthPayment = [NSString stringWithFormat:@"¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:GENERAL_COLOR_RED
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:GENERAL_FONT18
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    lblMonthPayment.attributedText = attributedString;
    
    if (indexPath.row == _goodsArr.count - 1) {
        if (_pageNum < _pageTotal) {
            _pageNum++;
            [self getGoodsListFromAPI];
        }
    }
    
    return cell;
}


#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _goodsArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *theGoods = _goodsArr[indexPath.row];
    GoodsItemCell *cell = (GoodsItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsIdentifier" forIndexPath:indexPath];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderColor:[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [cell.layer setBorderWidth:0.5];
    [cell.layer setCornerRadius:2];
    [cell.GoodsImage sd_setImageWithURL:[NSURL URLWithString:[theGoods objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    cell.GoodsTitle.text = [theGoods objectForKey:@"name"];
    cell.GoodsMonthSupply.text = [NSString stringWithFormat:@"月供：¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    cell.GoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.f", [[theGoods objectForKey:@"price"] floatValue]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cell.GoodsMonthSupply.text];
    NSString *tmpMonthPayment = [NSString stringWithFormat:@"¥%0.f", [[theGoods objectForKey:@"month_price"] floatValue]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:GENERAL_COLOR_RED
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:GENERAL_FONT18
                             range:NSMakeRange(3, tmpMonthPayment.length)];
    cell.GoodsMonthSupply.attributedText = attributedString;
    
    if (indexPath.row == _goodsArr.count - 1) {
        if (_pageNum < _pageTotal) {
            _pageNum++;
            [self getGoodsListFromAPI];
        }
    }
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(_cellWidth, _cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
    vc.goodsID = [_goodsArr[indexPath.row] objectForKey:@"goods"];
    [AppUtils pushPage:self targetVC:vc];
}


- (IBAction)doBack:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doListTypeChanged:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    
    if (self.listTypeSegment.selectedSegmentIndex == 0) {
        _listType = ListTypeList;
        self.goodsListTable.hidden = NO;
        self.goodsListCollection.hidden = YES;
        [self.goodsListCollection.layer addAnimation:animation forKey:nil];
    }
    else {
        _listType = ListTypeImage;
        self.goodsListTable.hidden = YES;
        self.goodsListCollection.hidden = NO;
        [self.goodsListCollection.layer addAnimation:animation forKey:nil];
    }

//    [self showListTypeSegment];
}

- (void)showListTypeSegment
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.listTypeSegment.layer addAnimation:animation forKey:nil];
    
    self.listTypeSegment.hidden = NO;
    if (_listType == ListTypeList) {
        if (self.goodsListTable.frame.origin.y < 70) {
            self.goodsListTable.frame = CGRectOffset(self.goodsListTable.frame, 0.0, 44.0);
        }
    }
    else
    {
        if (self.goodsListCollection.frame.origin.y < 70) {
            self.goodsListCollection.frame = CGRectOffset(self.goodsListCollection.frame, 0.0, 44.0);
        }
    }
}

- (void)hideListTypeSegment
{
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.4;
//    [self.listTypeSegment.layer addAnimation:animation forKey:nil];
    
    if ([[AppUtils iosVersion] floatValue] >= 8.0) {
        self.listTypeSegment.hidden = YES;
        if (_listType == ListTypeList) {
            if (self.goodsListTable.frame.origin.y > 70) {
                self.goodsListTable.frame = CGRectOffset(self.goodsListTable.frame, 0.0, -44.0);
            }
        }
        else
        {
            if (self.goodsListCollection.frame.origin.y > 70) {
                self.goodsListCollection.frame = CGRectOffset(self.goodsListCollection.frame, 0.0, -44.0);
            }
        }
    }
    
}

//#pragma UIScrollViewDelegate
//
//-(void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint currentOffset = scrollView.contentOffset;
//
//    if (currentOffset.y < 10 && self.listTypeSegment.isHidden == YES) {
//        [self showListTypeSegment];
//    }
//    
//    if (currentOffset.y >= 10 && self.listTypeSegment.isHidden == NO) {
//        [self hideListTypeSegment];
//    }
//    
//    _lastContentOffset = currentOffset;
//}


@end
