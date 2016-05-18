//
//  SearchViewController.m
//  renrenfenqi
//
//  Created by wangjianxing on 14/12/7.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "SearchViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "SearchResultViewController.h"

#define TAG_LBL 1
#define TAG_BUTTON 2

@interface SearchViewController ()
{
    float _viewWidth;
    float _viewHeight;
    
    NSArray *_cellIDArr;
    
    NSMutableArray *_searchHistoryArr;
    NSMutableArray *_hotGoodsArr;
}

@end

@implementation SearchViewController

/**
    热搜关键字  获取接口
 */
- (void)getSearchHotGoodsFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, SEARCH_HOT_GOODS];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _hotGoodsArr = [jsonData objectForKey:@"data"];
            
            [self.tableSearch reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)resignAllFirstResponder{
    //注销当前焦点
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doSearchAction:nil];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    self.tableSearch.dataSource = self;
    self.tableSearch.delegate = self;
    self.tableSearch.tableFooterView = [UIView new];
    
    self.txtKeyword.delegate = self;
    
    _hotGoodsArr = [NSMutableArray array];
    _searchHistoryArr = [NSMutableArray array];
    
    //获取搜索关键字历史
    if ([persistentDefaults objectForKey:@"searchHistory"] != nil) {
        _searchHistoryArr = [[persistentDefaults objectForKey:@"searchHistory"] mutableCopy];
    }
    
    _cellIDArr = @[@"hotKeywordIdentifier", @"searchHistoryTitleIdentifier", @"history1Identifier", @"history2Identifier", @"histry3Identifier", @"blankIdentifier", @"clearHistoryIdentifier"];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, 63.0, _viewWidth, 0.5)];
    line.backgroundColor = GENERAL_COLOR_GRAY;
    [self.view addSubview:line];
    
    [self getSearchHotGoodsFromAPI];

    //初始化手势监听，用于点击关闭键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignAllFirstResponder)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
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
    
    //点击搜索历史记录，进行搜索
    if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *lblHistory = (UILabel *)[cell viewWithTag:TAG_LBL];
        NSString *theKeyword = lblHistory.text;
        if (![AppUtils isNullStr:theKeyword]) {
            SearchResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultIdentifier"];
            vc.keyword = theKeyword;
            [AppUtils pushPage:self targetVC:vc];
        }
    }
//    GoodsDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailIdentifier"];
//    vc.goodsID = [_goodsArr[indexPath.row] objectForKey:@"goods"];
//    [AppUtils pushPage:self targetVC:vc];
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
    return 7;
}

- (void)doHotSearch:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    SearchResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultIdentifier"];
    vc.keyword = btn.titleLabel.text;
    [AppUtils pushPage:self targetVC:vc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[_cellIDArr objectAtIndex:indexPath.row] forIndexPath:indexPath];
    
    if (indexPath.row == 0 || indexPath.row == 1 | indexPath.row == 6)
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, 43.5, 15.0, 0.5)];
        line.backgroundColor = GENERAL_COLOR_GRAY;
        [cell addSubview:line];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            UILabel *lblHotGoods = (UILabel *)[cell viewWithTag:TAG_LBL];
            NSString *hotGoodsStr = @"";
            float theLeft = 80.0;
            if (_hotGoodsArr.count > 0) {
                for (id strItem in _hotGoodsArr) {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                    btn.tintColor = [UIColor lightGrayColor];
                    btn.frame = CGRectMake(theLeft, 7.0, 60.0, 30.0);
                    [btn setTitle:strItem forState:UIControlStateNormal];
                    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
                    btn.titleLabel.font = GENERAL_FONT15;
                    [btn addTarget:self action:@selector(doHotSearch:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:btn];
                    theLeft += 70.0;
                }
            }
//            lblHotGoods.text = [NSString stringWithFormat:@"热搜关键词：%@", hotGoodsStr];
            lblHotGoods.text = [NSString stringWithFormat:@"热搜关键词：%@", hotGoodsStr];
        }
            break;
        case 1:
        {
            UILabel *lblHotGoods = (UILabel *)[cell viewWithTag:TAG_LBL];
            if (_searchHistoryArr.count == 0) {
                lblHotGoods.text = @"";
            }
            else
            {
                lblHotGoods.text = @"最近搜索：";
            }
        }
            break;
        case 2:
        case 3:
        case 4:
        {
            UILabel *lblHistory = (UILabel *)[cell viewWithTag:TAG_LBL];
            lblHistory.text = @"";
            if (_searchHistoryArr.count > (indexPath.row - 2)) {
                lblHistory.text = [_searchHistoryArr objectAtIndex:indexPath.row - 2];
            }
        }
            break;
        case 6:
        {
            UIButton *btn = (UIButton *)[cell viewWithTag:TAG_BUTTON];
            if (_searchHistoryArr.count == 0)
            {
                btn.hidden = YES;
            }
            else
            {
                btn.hidden = NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)addSearchHistory:(NSString *)theKeyword
{
    int i = 0;
    for (id keywordItem in _searchHistoryArr) {
        if ([theKeyword isEqualToString:keywordItem]) {
            break;
        }
        
        i++;
    }
    
    if (i == _searchHistoryArr.count) {
        if (_searchHistoryArr.count >= 3) {
            [_searchHistoryArr removeLastObject];
            [_searchHistoryArr addObject:theKeyword];
        }
        else
        {
                    MyLog(@"====");
            [_searchHistoryArr addObject:theKeyword];
        }
    }
    else
    {
        [_searchHistoryArr removeObject:theKeyword];
        [_searchHistoryArr addObject:theKeyword];
    }
    
    [self.tableSearch reloadData];
    
    [persistentDefaults setObject:[_searchHistoryArr copy] forKey:@"searchHistory"];
//    MyLog(@"OKKK");
//    MyLog(_searchHistoryArr.description);
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doSearchAction:(id)sender {
    MyLog(@"searchAction");
    
    NSString *theKeyword = [AppUtils trimWhite:self.txtKeyword.text];
    if (theKeyword.length == 0) {
        [AppUtils showInfo:@"搜索内容不能为空"];
        return;
    }
    
    [self addSearchHistory:theKeyword];
    
    SearchResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultIdentifier"];
    vc.keyword = theKeyword;
    [AppUtils pushPage:self targetVC:vc];
}


- (IBAction)doClearSearchHistory:(id)sender {
    MyLog(@"clearhistory");
    
    [_searchHistoryArr removeAllObjects];
    [persistentDefaults removeObjectForKey:@"searchHistory"];
    
    [self.tableSearch reloadData];
}
@end
