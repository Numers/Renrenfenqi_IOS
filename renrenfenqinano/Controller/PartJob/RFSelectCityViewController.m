//
//  RFSelectCityViewController.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFSelectCityViewController.h"
#import "BATableView.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "RFCity.h"
#import "CalculateViewFrame.h"
#import "RFPartJobManager.h"
#import "MBProgressHUD.h"
#import "AppUtils.h"
#import "RFLocationHelper.h"
#define TitleLabelFont [UIFont boldSystemFontOfSize:16.f]
#define TitleLabelColor [UIColor colorWithRed:26/255.f green:26/255.f blue:26/255.f alpha:1.f]

static NSString *cellIdentify = @"CityCell";
static NSString *gpsCityHeader = @"#";
static NSString *hotHeader = @"热门城市";
@interface RFSelectCityViewController ()<BATableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate>
{
    RFCity *gpsCity;
    NSMutableArray *sectionRows;//全部数据
    NSMutableArray *filterSectionRows;//过滤后数据
    NSMutableArray *sections;//全部section
    NSMutableArray *filterSections;//过滤后分类
    NSMutableArray *cityList;
}
@property(nonatomic, strong) BATableView *tableView;
@property(nonatomic, strong) UISearchBar *searchBar;
@end

@implementation RFSelectCityViewController
-(id)initWithGpsCity:(RFCity *)gCity
{
    self = [super init];
    if (self) {
        gpsCity = gCity;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0f)];
//    [_searchBar setPlaceholder:@"输入城市名查询"];
//    _searchBar.delegate = self;
//    [self.view addSubview:_searchBar];
//    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController isShowNav:YES withTabBarController:self.tabBarController isShowTabBar:NO];
//    _tableView = [[BATableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + _searchBar.frame.size.height, frame.size.width, frame.size.height - _searchBar.frame.size.height)];
//    _tableView.delegate = self;
//    [self.view addSubview:_tableView];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController isShowNav:YES withTabBarController:self.tabBarController isShowTabBar:NO];
    _tableView = [[BATableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [self requestAllOpenCity];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    [self.navigationItem setTitle:@"选择城市"];
}

-(void)requestAllOpenCity
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[RFPartJobManager defaultManager] requestCityListSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSArray *dataArr = [resultDic objectForKey:@"data"];
            if (dataArr && dataArr.count > 0) {
                cityList = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in dataArr) {
                    RFCity *city = [[RFCity alloc] init];
                    city.cityId = [[dic objectForKey:@"city_id"] integerValue];
                    city.cityName = [dic objectForKey:@"name"];
                    [cityList addObject:city];
                }
                [self initlizedSectionsAndSectionRows];
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [AppUtils showError:[responseObject objectForKey:@"message"]];
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [AppUtils showError:@"网络连接失败"];
    }];
}

-(void)initlizedSectionsAndSectionRows
{
    if (filterSectionRows == nil) {
        filterSectionRows = [[NSMutableArray alloc] init];
    }else{
        [filterSectionRows removeAllObjects];
    }
    
    if(filterSections == nil){
        filterSections = [[NSMutableArray alloc] init];
    }else{
        [filterSections removeAllObjects];
    }
    
    if ((cityList == nil) || (cityList.count == 0)) {
        return;
    }
    
    if (sections == nil) {
        sections = [[NSMutableArray alloc] init];
    }else{
        [sections removeAllObjects];
    }
    
    if (sectionRows == nil) {
        sectionRows = [[NSMutableArray alloc] init];
    }else{
        [sectionRows removeAllObjects];
    }
    
//    //处理城市列表
//    [self dowithCityList];
//    //添加热门城市
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"HotCity" ofType:@"plist"];
//    NSArray *hotCityIdList = [NSArray arrayWithContentsOfFile:path];
//    if ((hotCityIdList != nil) && (hotCityIdList.count > 0)) {
//        NSMutableArray *hotCityList = [[NSMutableArray alloc] init];
//        for (NSNumber *m in hotCityIdList) {
//            RFCity *city = [self searchCityWithCityId:[m integerValue]];
//            if (city != nil) {
//                [hotCityList addObject:city];
//            }
//        }
//        if (hotCityList.count > 0) {
//            [sections insertObject:hotHeader atIndex:0];
//            [sectionRows insertObject:hotCityList atIndex:0];
//        }
//    }
    
    //添加热门城市
    [sections insertObject:hotHeader atIndex:0];
    [sectionRows insertObject:cityList atIndex:0];

    //添加定位城市
    NSArray *gpsCityList = nil;

    if (gpsCity != nil) {
        gpsCityList = [NSArray arrayWithObject:gpsCity];
    }else{
        RFCity *nullCity = [[RFCity alloc] init];
        nullCity.cityName = gpsCityHeader;
        gpsCityList = [NSArray arrayWithObject:nullCity];
    }
    
    [sections insertObject:gpsCityHeader atIndex:0];
    [sectionRows insertObject:gpsCityList atIndex:0];
    //初始化数据源
    [filterSectionRows addObjectsFromArray:sectionRows];
    [filterSections addObjectsFromArray:sections];
    //刷新tableview
    [_tableView reloadData];
}

-(RFCity *)searchCityWithCityName:(NSString *)cityName
{
    if (cityName == nil) {
        return nil;
    }
    RFCity *city = nil;
    //如果有市 把市去掉
    NSRange range = [cityName rangeOfString:@"市"];
    NSString * cityStr = cityName;
    if (range.length>0) {
        cityStr = [cityName substringToIndex:range.location];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName = %@",cityStr];
    NSArray *array = [cityList filteredArrayUsingPredicate:predicate];
    
    if ((array != nil) && (array.count > 0)) {
        city = [array lastObject];
    }
    return city;
}

-(void)dowithCityList
{
    for (RFCity *m in cityList) {
        NSString *character = [[[PinYinForObjc chineseConvertToPinYinHead:m.cityName] substringToIndex:1] uppercaseString];
        [self addDifferentCharacterIntoSectionsArray:character];
    }
    
    [sections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch|NSCaseInsensitiveSearch];
    }];
    
    for (NSString *head in sections) {
        NSMutableArray *filterArr = [[NSMutableArray alloc] init];
        for (RFCity *c in cityList) {
            NSString *cityHeadName = [[[PinYinForObjc chineseConvertToPinYinHead:c.cityName] substringToIndex:1] uppercaseString];
            if ([head isEqualToString:cityHeadName]) {
                [filterArr addObject:c];
            }
        }
        
        NSMutableArray *sectionRowsMember = [[NSMutableArray alloc] initWithArray:filterArr];
        if (sectionRowsMember.count > 0) {
            [sectionRows addObject:sectionRowsMember];
        }
    }
}

-(void)addDifferentCharacterIntoSectionsArray:(NSString *)character
{
    if (character) {
        if (![sections containsObject:character]) {
            [sections addObject:character];
        }
    }
}

-(RFCity *)searchCityWithCityId:(NSInteger)cityId
{
    RFCity *city = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityId = %ld",cityId];
    NSArray *array = [cityList filteredArrayUsingPredicate:predicate];
    
    if ((array != nil) && (array.count > 0)) {
        city = [array lastObject];
    }
    return city;
}

-(void)filterCityListWithSearchText:(NSString *)searchText
{
    if (filterSectionRows == nil) {
        filterSectionRows = [[NSMutableArray alloc] init];
    }else{
        [filterSectionRows removeAllObjects];
    }
    
    if (filterSections == nil) {
        filterSections = [[NSMutableArray alloc] init];
    }else{
        [filterSections removeAllObjects];
    }
    
    if ((searchText == nil) || (searchText.length == 0)) {
        [filterSectionRows addObjectsFromArray:sectionRows];
        [filterSections addObjectsFromArray:sections];
    }else{
        NSString *nameLikeStr = [NSString stringWithFormat:@"*%@*",searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName LIKE[cd] %@",nameLikeStr];
        for (NSInteger i = 0; i < sectionRows.count; i++) {
            NSArray *rows = [sectionRows objectAtIndex:i];
            NSArray *filterArr = [rows filteredArrayUsingPredicate:predicate];
            if ((filterArr == nil) || (filterArr.count == 0)) {
                continue;
            }
            [filterSectionRows addObject:filterArr];
            [filterSections addObject:[sections objectAtIndex:i]];
        }
    }
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma -mark searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSelector:@selector(filterCityListWithSearchText:) withObject:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(NSMutableAttributedString *)generateAttriuteStringWithStr:(NSString *)str WithColor:(UIColor *)color WithFont:(UIFont *)font
{
    if (str == nil) {
        return nil;
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range;
    range.location = 0;
    range.length = attrString.length;
    [attrString beginEditing];
    [attrString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,font,NSFontAttributeName, nil] range:range];
    [attrString endEditing];
    return attrString;
}

#pragma -mark TableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
//{
//    return 44.0f;
//}
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray *titles = [NSMutableArray arrayWithArray:filterSections];
    [titles removeObject:hotHeader];
    return titles;
}

-(void)scrollToRowWithHeaderTitle:(NSString *)title WithSection:(NSInteger)section
{
    section = [filterSections indexOfObject:title];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionMemberArr = [filterSectionRows objectAtIndex:indexPath.section];
    RFCity *selectCity = [sectionMemberArr objectAtIndex:indexPath.row];
    if ([selectCity.cityName isEqualToString:gpsCityHeader]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(selectCity:)]) {
        if ([selectCity isEqual:gpsCity]) {
            if (![[RFLocationHelper defaultHelper] isCityOpen]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"当前城市%@未开通相关业务",selectCity.cityName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        }
        [self.delegate selectCity:selectCity];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return filterSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionMemberArr = [filterSectionRows objectAtIndex:section];
    NSInteger result = sectionMemberArr.count;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentify];
    }
    
    NSArray *sectionRowsMember = [filterSectionRows objectAtIndex:indexPath.section];
    id obj = [sectionRowsMember objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[RFCity class]]){
        RFCity *city = (RFCity *)obj;
        if ([city.cityName isEqualToString:gpsCityHeader]) {
            [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"暂无定位城市" WithColor:[UIColor grayColor] WithFont:TitleLabelFont]];
        }else{
            [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:city.cityName WithColor:TitleLabelColor WithFont:TitleLabelFont]];
        }
    }else{
        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"暂无定位城市" WithColor:[UIColor grayColor] WithFont:TitleLabelFont]];
    }
    
    NSString *header = [filterSections objectAtIndex:indexPath.section];
    if ([header isEqualToString:gpsCityHeader]) {
        if ([obj isKindOfClass:[RFCity class]])
        {
            RFCity *city = (RFCity *)obj;
            if ([city.cityName isEqualToString:gpsCityHeader]) {
                cell.detailTextLabel.text = nil;
            }else{
                cell.detailTextLabel.text = @"GPS定位";
            }
        }else{
            cell.detailTextLabel.text = nil;
        }
    }else{
        cell.detailTextLabel.text = nil;
    }
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        @autoreleasepool {
    //            //Data processing
    //            City *city = (City *)[sectionRowsMember objectAtIndex:indexPath.row];
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                //Update Interface
    //                [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:city.cityName WithColor:TitleLabelColor WithFont:TitleLabelFont]];
    //
    //                NSString *header = [filterSections objectAtIndex:indexPath.section];
    //                if ([header isEqualToString:gpsCityHeader]) {
    //                    cell.detailTextLabel.text = @"GPS定位";
    //                }else{
    //                    cell.detailTextLabel.text = nil;
    //                }
    //
    //            });
    //        }
    //    });
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *result = nil;
    NSString *header = [filterSections objectAtIndex:section];
    if ([header isEqualToString:gpsCityHeader]) {
        result = nil;
    }else{
        result = [filterSections objectAtIndex:section];
    }
    return result;
}

#pragma -mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

@end
