//
//  SecondViewController.m
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "CategoriesViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "CategoriesGoodsListViewController.h"
#import "SearchViewController.h"
#import "MJRefresh.h"
#import "UIButton+WebCache.h"

#define TAG @"Categories"

@interface CategoriesViewController ()
{
    float _viewWidth;
    float _viewHeight;
    
    float _buttonWidth;
    float _categoryWidth;
    
    int _selectCategory;
    
    int _rowCount;
    int _categoryLineCount;
    
    NSMutableArray *_categoryArr;
}

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    UIView *lineView = [AppUtils makeLine:_viewWidth theTop:64.0];
//    lineView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    
    _buttonWidth = (_viewWidth - 2.0) / 4.0;
    _categoryWidth = (_viewWidth - 2.0) / 3.0;
    
    _categoryArr = [NSMutableArray array];
    if ([persistentDefaults objectForKey:@"CategoriesData"]) {
        _categoryArr = [persistentDefaults objectForKey:@"CategoriesData"];
    }

//    [self getCategoriesFromAPI];
    
    self.tableCategories.delegate = self;
    self.tableCategories.dataSource = self;
    //    if ([self.tableCategories respondsToSelector:@selector(setSeparatorInset:)]) {
    //        [self.tableCategories setSeparatorInset:UIEdgeInsetsZero];
    //    }
    //    if ([self.tableCategories respondsToSelector:@selector(setLayoutMargins:)]) {
    //        [self.tableCategories setLayoutMargins:UIEdgeInsetsZero];
    //    }
    //    self.tableCategories.separatorColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    
    _selectCategory = -1000;
    _rowCount = 0;
    _categoryLineCount = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_categoryArr.count == 0) {
        [self getCategoriesFromAPI];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if (indexPath.row == (int)(_selectCategory / 3) + 1 )
    {
        cell.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
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
    float cellHeight;
    if (indexPath.row == (int)(_selectCategory / 3) + 1 ) {
        NSDictionary *theCategory = [_categoryArr objectAtIndex:_selectCategory];
        NSArray *subCatecaryArr = [theCategory objectForKey:@"second"];
        
        int j = ceil(subCatecaryArr.count / 4.0);
        float top = 15.0 + (15.0 + 21.0) * j;
        cellHeight =  top;
    }
    else
    {
        cellHeight =  _categoryWidth + 0.5;
    }
    
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _rowCount;
}

- (void)doTapCategory:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (_rowCount == _categoryLineCount + 1) {   //已展开
        
        if ( _selectCategory == (int)btn.tag ) {
            [self.tableCategories beginUpdates];
            _selectCategory = (int)btn.tag;
            
            NSIndexPath* lastIndexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) inSection:0];
            [self.tableCategories reloadRowsAtIndexPaths:[NSArray arrayWithObjects:lastIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) + 1 inSection:0];
            [self.tableCategories deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            _rowCount = _categoryLineCount;
            _selectCategory = -1000;
            [self.tableCategories endUpdates];
            
        }
        else
        {
            if ((int)(_selectCategory / 3) == (int)btn.tag / 3) { //同一行
                _selectCategory = (int)btn.tag;
                _rowCount = _categoryLineCount + 1;
                
                [self.tableCategories beginUpdates];
                NSIndexPath* lastIndexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) inSection:0];
                [self.tableCategories reloadRowsAtIndexPaths:[NSArray arrayWithObjects:lastIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) + 1 inSection:0];
                [self.tableCategories reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableCategories endUpdates];
            }
            else
            {
                _selectCategory = -1000;
                _rowCount = _categoryLineCount;
                [self.tableCategories reloadData];
                
                [self.tableCategories beginUpdates];
                _selectCategory = (int)btn.tag;
                
                NSIndexPath* lastIndexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) inSection:0];
                [self.tableCategories reloadRowsAtIndexPaths:[NSArray arrayWithObjects:lastIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) + 1 inSection:0];
                [self.tableCategories insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                _rowCount = _categoryLineCount + 1;
                [self.tableCategories endUpdates];
            }
        }
        
    }
    else if (_rowCount == _categoryLineCount)    //未展开
    {
        [self.tableCategories beginUpdates];
        _selectCategory = (int)btn.tag;
        
        NSIndexPath* lastIndexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) inSection:0];
        [self.tableCategories reloadRowsAtIndexPaths:[NSArray arrayWithObjects:lastIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(int)(_selectCategory / 3) + 1 inSection:0];
        [self.tableCategories insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        _rowCount = _categoryLineCount + 1;
        [self.tableCategories endUpdates];
    }
    
}

- (void)makeCell:(int)i curRow:(int)curRow cell:(UITableViewCell *)cell
{
    NSDictionary *theCategory = [_categoryArr objectAtIndex:curRow * 3 + i];
    
    float imageLeft = (_categoryWidth + 0.5) * i + (_categoryWidth - 60.0) * 0.5;
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 sd_setImageWithURL:[NSURL URLWithString:[theCategory objectForKey:@"img_path"]] forState:UIControlStateNormal];
    btn1.frame = CGRectMake(imageLeft, (_categoryWidth - 90.0) * 0.5, 60.0, 60.0);
    btn1.tag = curRow * 3 + i;
    [btn1 addTarget:self action:@selector(doTapCategory:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn1];
    
    float nameLeft = (_categoryWidth + 0.5) * i + 5.0;
    
    UIButton *btnName = [UIButton buttonWithType:UIButtonTypeSystem];
    btnName.frame = CGRectMake(nameLeft, (_categoryWidth - 90.0) * 0.5 + 60.0 + 10.0, _categoryWidth - 10.0, 21.0);
    btnName.tag = curRow * 3 + i;
    btnName.tintColor = [UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0];
    [btnName setTitle:[theCategory objectForKey:@"display_name"] forState:UIControlStateNormal];
    [btnName addTarget:self action:@selector(doTapCategory:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnName];
}

- (void)doTapSubCategory:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *theCategory = [_categoryArr objectAtIndex:_selectCategory];
    NSArray *subCatecaryArr = [theCategory objectForKey:@"second"];
    
    CategoriesGoodsListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesGoodsListIdentifier"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.type = [subCatecaryArr[btn.tag] objectForKey:@"type"];
    if ([vc.type isEqualToString:@"category"]) {
        vc.categoryName = [subCatecaryArr[btn.tag] objectForKey:@"cname"];
    }
    else if ([vc.type isEqualToString:@"brand"])
    {
        vc.brandID = [subCatecaryArr[btn.tag] objectForKey:@"brand_id"];
    }
    [AppUtils pushPage:self targetVC:vc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (_rowCount == _categoryLineCount)
    {
        int curRow = (int)indexPath.row;
        
        for (int i = 0; i < 3; i++) {
            //bottom line
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake((_categoryWidth + 0.5) * i, _categoryWidth, _categoryWidth, 0.5)];
            separatorView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
            [cell addSubview:separatorView];
                
            if (curRow * 3 + i < _categoryArr.count)
            {
                [self makeCell:i curRow:curRow cell:cell];
            }
            
            //right line
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((_categoryWidth + 0.5) * i + _categoryWidth, 0.0, 0.5, _categoryWidth)];
            lineView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
            [cell addSubview:lineView];
        }
    }
    else if(_rowCount == _categoryLineCount + 1)
    {
        if (indexPath.row == (int)(_selectCategory / 3) + 1 ) {
            //do some
            
            NSDictionary *theCategory = [_categoryArr objectAtIndex:_selectCategory];
            NSArray *subCatecaryArr = [theCategory objectForKey:@"second"];
            
            //二级目录生成
            int top = 0;
            for (int i = 0; i < subCatecaryArr.count; i++) {
                int j = i / 4;
                top = 15.0 + (15.0 + 21.0) * j;
                int left = _buttonWidth * (i % 4);
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.frame = CGRectMake(left, top, _buttonWidth, 21.0);
                [btn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
                [btn setTitle:[subCatecaryArr[i] objectForKey:@"display_name"] forState:UIControlStateNormal];
                btn.tag = i;
                [btn addTarget:self action:@selector(doTapSubCategory:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
            }
            
            int j = ceil(subCatecaryArr.count / 4.0);
            float theTop = 15.0 + (15.0 + 21.0) * j;
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, theTop, _viewWidth, 0.5)];
            separatorView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
            [cell addSubview:separatorView];
        }
        else
        {
            int curRow = (int)indexPath.row;
            
            if (curRow > ((int)(_selectCategory / 3) + 1) ) {
                curRow = curRow - 1;
            }
            
            for (int i = 0; i < 3; i++) {
                
                //bottom line
                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake((_categoryWidth + 0.5) * i, _categoryWidth, _categoryWidth, 0.5)];
                separatorView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
                [cell addSubview:separatorView];
                
                if (curRow * 3 + i == _selectCategory) {
                    UIImageView *imgBg = [[UIImageView alloc] initWithFrame:CGRectMake((_categoryWidth + 0.5) * i, 0.5, _categoryWidth, _categoryWidth)];
                    [imgBg setImage:[UIImage imageNamed:@"classification_body_blackground_1_n"]];
                    imgBg.tag = 1001;
                    [cell addSubview:imgBg];
                }
                    
                if (curRow * 3 + i < _categoryArr.count)
                {
                    [self makeCell:i curRow:curRow cell:cell];
                }
                    
                //right line
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((_categoryWidth + 0.5) * i + _categoryWidth, 0.0, 0.5, _categoryWidth)];
                lineView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
                [cell addSubview:lineView];

            }
            
        }
    }
    
    return cell;
}

- (void)getCategoriesFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, HOME_CATEGORIES] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            if (_categoryArr == nil || (![_categoryArr isEqualToArray:[jsonData objectForKey:@"data"]]))
            {
                _categoryArr = [[jsonData objectForKey:@"data"] mutableCopy];
                _categoryLineCount = ceil(_categoryArr.count / 3.0);
                _rowCount = _categoryLineCount;
                [persistentDefaults setObject:[jsonData objectForKey:@"data"] forKey:@"CategoriesData"];
                [self.tableCategories reloadData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (IBAction)doSearchAction:(id)sender {
    SearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}
@end
