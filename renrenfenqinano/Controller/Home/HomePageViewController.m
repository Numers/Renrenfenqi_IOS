//
//  HomePageViewController.m
//  renrenfenqi
//
//  Created by coco on 15-1-24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "HomePageViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "GoodsDetailSpecViewController.h"
#import "CommonWebViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "MyBillsViewController.h"
#import "WishViewController.h"
#import "RedPacketViewController.h"
#import "MyPointsViewController.h"
#import "UserLoginViewController.h"
#import "UserGuideViewController.h"
#import "MJRefresh.h"
#import "MobClick.h"

#import "OrderJobPaymentViewController.h"
#import "CommonTools.h"
#import "GoodsActivitiesViewController.h"
#import "ThemeViewController.h"
#import "HomePageFunctionTableViewCell.h"
#import "RFPartJobViewController.h"

#import "IntroViewController.h"
#import "CreditAccountViewController.h"
#import "CurMonthRepaymentViewController.h"
#import "NeedPaymentListViewController.h"
#import "BillsListViewController.h"
#import "BillDetailViewController.h"
#import "LateFeeViewController.h"
#import "BillPaymentViewController.h"
#import "OrderWebViewController.h"
#import "OrderAddressAddViewController.h"
#import "EDSemver.h"

@interface HomePageViewController ()<HomePageFunctionTableViewCellProtocol>
{
    float _viewWidth;
    float _viewHeight;
    
    BOOL _noData;
    
    int _pageNum;
    int _pageTotal;
    
    NSArray *_storeyImagesArr;
    
    NSMutableArray *_adArr;
    NSMutableArray *_storeyArr;
    NSMutableArray *_topicArr;
    UIStoryboard *_secondStoryBord;
}



@end

@implementation HomePageViewController

- (void)getHomeDataFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@", SECURE_BASE, HOME_IF]);
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, HOME_IF] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//                MyLog(operation.responseString);
        self.tableHome.hidden = NO;
        [self.tableHome headerEndRefreshing];
        
        _noData = NO;
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            NSDictionary *dataDic = [[jsonData objectForKey:@"data"] mutableCopy];
            if (dataDic) {
                _noData = NO;
                _adArr = [dataDic objectForKey:@"banner"];
                _storeyArr = [dataDic objectForKey:@"hot"];
                [self.tableHome reloadData];
            }else{
                _noData = YES;
            }
        }else{
            _noData = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _noData = YES;
        self.tableHome.hidden = NO;
        [self.tableHome headerEndRefreshing];
    }];
}

- (void)test
{
    [self.tableHome reloadData];
}

//- (void)handleTopicsData:(NSDictionary *)result
//{
//    float tempTotal = [[result objectForKey:@"total"] floatValue] / [[result objectForKey:@"per_page"] intValue];
//    _pageTotal = [[NSString stringWithFormat:@"%0.f", ceil(tempTotal)] intValue];
//    
//    if (_pageNum == 1) {
//        _topicArr = [[result objectForKey:@"list"] mutableCopy];
//    }
//    if (_pageNum > 1) {
//        NSArray *ordersArr = [result objectForKey:@"list"];
//        [_topicArr addObjectsFromArray:ordersArr];
//    }
//    
//    [self.tableHome reloadData];
////    [self performSelector:@selector(test) withObject:self afterDelay:1.0];
//}
//
//- (void)getTopicsFromAPI
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
//    
//    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", _pageNum]};
//    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, TOPIC_LIST] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        //        MyLog(operation.responseString);
//        
//        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
//            [self handleTopicsData:[jsonData objectForKey:@"data"]];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
//    }];
//}

/**
    获取商品详情页面使用的HTML5压缩包，供商品详情页使用
 */
- (void)getHtml5NewVersion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, HTML5_NEWVERSION] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            EDSemver *newVersion  = [[EDSemver alloc] initWithString:[[jsonData objectForKey:@"data"] objectForKey:@"version"]];
            
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSString *strCurVersion = [app.store getStringById:HTML5_ZIP_VERSION fromTable:CFG_TABLE];
            EDSemver *curVersion = [[EDSemver alloc] initWithString:strCurVersion];
            if ([newVersion isGreaterThan:curVersion]) {
                MyLog(@"download version %@", [[jsonData objectForKey:@"data"] objectForKey:@"version"]);
                [self doDownloadWebAsset:[[jsonData objectForKey:@"data"] objectForKey:@"path"] newZipVersion:[[jsonData objectForKey:@"data"] objectForKey:@"version"]];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)doUserGuide {
//    UserGuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserGuideIdentifier"];
//    [AppUtils pushPage:self targetVC:vc];
//    [persistentDefaults setObject:@"1" forKey:@"isNewbie"];
    
    
    IntroViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
    [persistentDefaults setObject:@"1" forKey:@"isNewbie"];
}

- (void)refreshContent
{
    [self getHomeDataFromAPI];
    
//    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [app.store deleteObjectById:HTML5_ZIP_VERSION fromTable:CFG_TABLE];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    _secondStoryBord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _noData = YES;
    
    _adArr = [NSMutableArray array];
    _storeyArr = [NSMutableArray array];
    _topicArr = [NSMutableArray array];
    
    _storeyImagesArr = @[@"home_body_no1_n", @"home_body_no2_n", @"home_body_no3_n", @"home_body_no4_n", @"home_body_no5_n", @"home_body_no6_n"];
//    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _viewWidth, 65)];
//    topBar.backgroundColor = GENERAL_COLOR_RED2;
//    [self.view addSubview:topBar];
    
    self.tableHome.delegate = self;
    self.tableHome.dataSource = self;
    [self.tableHome registerClass:[HomePageFunctionTableViewCell class] forCellReuseIdentifier:@"HomepageFunctionTableViewCell"];
    if ([self.tableHome respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableHome setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableHome respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableHome setLayoutMargins:UIEdgeInsetsZero];
    }
    self.tableHome.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    
    _pageNum = 1;
    _pageTotal = 1;
    
    self.tableHome.hidden = YES;
    [self getHomeDataFromAPI];
    
    if (![persistentDefaults objectForKey:@"isNewbie"]) {
        [self performSelector:@selector(doUserGuide) withObject:nil afterDelay:0.5];
    }

//    [self doTest];
//    [self doDownloadWebAsset];

    [self.tableHome addHeaderWithTarget:self action:@selector(refreshContent)];
    self.tableHome.headerPullToRefreshText = @"下拉可以刷新了";
    self.tableHome.headerReleaseToRefreshText = @"松开马上刷新了";
    self.tableHome.headerRefreshingText = @"仁仁分期玩命刷新中";
    
    //更新App
    [MobClick updateOnlineConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    //首次进入应用将资源中HTML5压缩包(商品详情页使用)解压，
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *curZIPVersion = [app.store getStringById:HTML5_ZIP_VERSION fromTable:CFG_TABLE];
    if (!curZIPVersion) {  //首次进入应用
        NSString *zipPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"source.zip"];
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSError *zipError = nil;
        BOOL ok = [SSZipArchive unzipFileAtPath:zipPath toDestination:documentsDirectory overwrite:YES password:nil error:&zipError];
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&zipError];
        
        if (ok) {
            MyLog(@"zip copy to document");
            [app.store putString:@"2.5" withId:HTML5_ZIP_VERSION intoTable:CFG_TABLE];
        }
    } else {
        [self getHtml5NewVersion];
    }
}

- (void)onlineConfigCallBack:(NSNotification *)notification {
    if ([[[MobClick getConfigParams:@"isForceUpdate"] uppercaseString] isEqualToString:@"YES"]) {
        [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
    }
    else
    {
        [MobClick checkUpdate];
    }
}

- (void)appUpdate:(NSDictionary *)result
{
    self.updateResult = result;
    if ([[result objectForKey:@"update"] isEqualToString:@"YES"]) {
        NSString* verTitle = [NSString stringWithFormat:@"有可用的新版本%@", [result objectForKey:@"version"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:verTitle message:[result objectForKey:@"update_log"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"去AppStore升级",nil];
        [alert show];
    }
}

- (void)doTest
{
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        //                        OrderConfirmViewController *ocvc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmIdentifier"];
                        //                        ocvc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:ocvc animated:NO];
                        //                        OrderAddressAddViewController *oaavc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderAddressAddIdentifier"];
                        //                        oaavc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:oaavc animated:NO];
                        
                        //                        OrderAddressViewController *oavc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderAddressIdentifier"];
                        //                        oavc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:oavc animated:NO];
                        
                        //                        MyOrdersViewController *movc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyOrdersIdentifier"];
                        //                        movc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:movc animated:NO];
                        
                        //                        SearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchIdentifier"];
                        //                        vc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        GoodsRatesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsRatesIdentifier"];
                        //                        vc.hidesBottomBarWhenPushed = YES;
                        //                        vc.goodsID = @"33";
                        //                        [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        SearchResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultIdentifier"];
                        //                        vc.keyword = @"米";
                        //                        vc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        OrderDetailViewController *odvc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailIdentifier"];
                        //                        odvc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:odvc animated:NO];
                        
                        //                        OrderEvaluateViewController *odvc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderEvaluateIdentifier"];
                        //                        odvc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:odvc animated:NO];
                        
                        //                        OrderDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailIdentifier"];
                        //                        vc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        UserLoginViewController *odvc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
                        //                        odvc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:odvc animated:NO];
                        
                        //                        MyBillsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsIdentifier"];
                        //                        vc.hidesBottomBarWhenPushed = YES;
                        //                        [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        //                        if(app.secondStoryBord == nil){
                        //                            app.secondStoryBord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
                        //                        }
                        //                        PersonalCenterViewController *centerVC = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"PersonalCenterIdentifier"];
                        ////                        WishViewController *wishvc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"WishIdentifier"];
                        //                        [self.navigationController pushViewController:centerVC animated:NO];
                        
                        //                        AddressSelectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressSelectIdentifier"];
                        //                                                vc.hidesBottomBarWhenPushed = YES;
                        //                        vc.curPos = 0;
                        ////                        vc.rectID = @"3229";
                        //                                                [self.navigationController pushViewController:vc animated:NO];
                        
                        //                        MyBillsAutoRepaymentOKViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsAutoRepaymentOKIdentifier"];
                        //                        [AppUtils pushPage:self targetVC:vc];
                        //                        JobSettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JobSettingIdentifier"];
                        //                        [AppUtils pushPage:self targetVC:vc];
                        
                        //                        GoodsDetailSpecViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailSpecIdentifier"];
                        //                        [AppUtils pushPage:self targetVC:vc];
                        
                        
//                        HomePageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageIdentifier"];
//                        [AppUtils pushPage:self targetVC:vc];
                        
//                            OrderJobPaymentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderJobPaymentIdentifier"];
//                            [AppUtils pushPage:self targetVC:vc];
                        
//                        [self doUserGuide];
                        
                        OrderAddressAddViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderAddressAddIdentifier"];
                        [AppUtils pushPage:self targetVC:vc];
                        
                        //TODO FUCK TODO
                        
                    }
                    completion:NULL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tableHome reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    if (_storeyArr && _storeyArr .count > 0) {
        if (indexPath.row > 3 && indexPath.row < 3+_storeyArr.count) {
            NSDictionary *dic = [_storeyArr objectAtIndex:indexPath.row - 3];
            OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
            vc.goodsID = [dic objectForKey:@"goods"];
            vc.hidesBottomBarWhenPushed = YES;
            [AppUtils pushPage:self targetVC:vc];
        }
    }
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float theHeight = 69.0;
    
    switch (indexPath.row) {
        case 0:
        {
            theHeight = ceil(_viewWidth * 3 / 8);
        }
            break;
        case 1:
        {
            theHeight = ceil(_viewWidth / 3) * 140.0f / 213.0f;
        }
            break;
        case 2:
        {
            theHeight = 42.0;
        }
            break;
    }
    return theHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_noData) {
        return 0;
    }
    else
    {
        if (_storeyArr && _storeyArr.count > 0) {
            return 3 + _storeyArr.count;
        }else{
            return 3;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImagesIdentifier" forIndexPath:indexPath];
            
//            if (![cell viewWithTag:1]) {
            if ([cell viewWithTag:1]) {
                [[cell viewWithTag:1] removeFromSuperview];
            }
                if (_adArr.count > 0) {
                    NSMutableArray *imagesArr = [NSMutableArray array];
                    int i = 0;
                    for (id adItem in _adArr) {
                        NSString *theUrl = [adItem objectForKey:@"img_path"];
                        SGFocusImageItem *item1 = [[SGFocusImageItem alloc] initWithTitle:@"title1" image:[UIImage imageNamed:@"ios_banner_the_default_background"] tag:i url:theUrl];
                        [imagesArr addObject:item1];
                        i++;
                    }
                    
                    SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:cell.frame
                                                                                    delegate:self
                                                                       focusImageItemsArrray:imagesArr];
                    imageFrame.autoScrolling = YES;
                    imageFrame.tag = 1;
                    [cell addSubview:imageFrame];
                }
//            }
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HomepageFunctionTableViewCell" forIndexPath:indexPath];
            HomePageFunctionTableViewCell *homepageCell = (HomePageFunctionTableViewCell *)cell;
            homepageCell.delegate = self;
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
        }
            break;
//        case 3:
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"StoreyIdentifier" forIndexPath:indexPath];
//        }
//            break;
            
        default:
            break;
    }
    
    //storey
    if (_storeyArr && _storeyArr.count > 0) {
        if (indexPath.row > 2 && indexPath.row < (3 + _storeyArr.count)) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"StoreyIdentifier" forIndexPath:indexPath];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    //Data processing
                    NSDictionary *dic = [_storeyArr objectAtIndex:indexPath.row - 3];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Update Interface
                        NSString *type = [dic objectForKey:@"type"];
                        if ([type isEqualToString:@"goods"]) {
                            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
                            [imageView sd_setImageWithURL:[dic objectForKey:@"img_path"] placeholderImage:[UIImage imageNamed:@"Homepage_GoodIndexLogo"]];
                            UILabel *goodLabel = (UILabel *)[cell viewWithTag:2];
                            [goodLabel setText:[dic objectForKey:@"name"]];
                            UIButton *perMonthPriceButton = (UIButton *)[cell viewWithTag:3];
                            float monthPrice = [[dic objectForKey:@"month_price"] floatValue];
                            NSMutableAttributedString *moneySymbolAndMoney = [self generateAttriuteStringWithStr:@"¥" WithColor:[UIColor colorWithRed:242/255.0f green:67/255.0f blue:82/255.0f alpha:1.0f] WithFont:[UIFont systemFontOfSize:7.0f]];
                            NSMutableAttributedString *money = [self generateAttriuteStringWithStr:[NSString stringWithFormat:@"%.2f",monthPrice] WithColor:[UIColor colorWithRed:242/255.0f green:67/255.0f blue:82/255.0f alpha:1.0f] WithFont:[UIFont systemFontOfSize:18.0f]];
                            [moneySymbolAndMoney appendAttributedString:money];
                            NSAttributedString *lablePermonthPrice = [[NSAttributedString alloc] initWithAttributedString:moneySymbolAndMoney];
                            [perMonthPriceButton setAttributedTitle:lablePermonthPrice forState:UIControlStateNormal];
                            UILabel *periodsLabel = (UILabel *)[cell viewWithTag:4];
                            [periodsLabel setText:[NSString stringWithFormat:@"✕ %@期",[dic objectForKey:@"period"]]];
                        }
                    });
                }
            });
        }
    }
    return cell;
}

#pragma mark - SGFocusImageFrame
- (void)doGoAdGoods:(SGFocusImageItem *)item
{
    NSDictionary *theBanner = [_adArr objectAtIndex:item.tag];
    if ([[theBanner objectForKey:@"type"] isEqualToString:@"goods"]) {
        OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
        vc.goodsID = [theBanner objectForKey:@"goods"];
        vc.hidesBottomBarWhenPushed = YES;
        [AppUtils pushPage:self targetVC:vc];
    }
    else if ([[theBanner objectForKey:@"type"] isEqualToString:@"active"]){
        [self handleActivityJump:[theBanner objectForKey:@"url"]];
    }
}

- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if (item.tag == 1004) {
        [imageFrame removeFromSuperview];
    }
    
    [self doGoAdGoods:item];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doRepaymentAction:(id)sender
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        CreditAccountViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditAccountIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }else{
        [self doLogin];
        [AppUtils showLoadInfo:@"请登录账号"];
    }
}

- (IBAction)doWishListAction:(id)sender
{
    WishViewController *vc = [_secondStoryBord instantiateViewControllerWithIdentifier:@"WishIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doRedPacketAction:(id)sender
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        MyPointsViewController *vc = [_secondStoryBord  instantiateViewControllerWithIdentifier:@"MyPointsIdentifier"];
        [AppUtils pushPage:self targetVC:vc];
    }else{
        [self doLogin];
        [AppUtils showLoadInfo:@"请登录账号"];
    }
}

- (IBAction)doPointsAction:(id)sender
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    if ([AppUtils isLogined:userId]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
        
        NSDictionary *parameters = @{@"uid":userId};
        
        [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, USER_SIGN_IN] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary* jsonData = [operation.responseString objectFromJSONString];
            
            
            if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];
            }
            
            if ([[jsonData objectForKey:@"message"] isKindOfClass:[NSString class]]) {
                [AppUtils showLoadInfo:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"message"]]];
            }
            else
            {
                [AppUtils showLoadInfo:[NSString stringWithFormat:@"签到成功 积分+%@", [jsonData objectForKey:@"message"]]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppUtils showLoadInfo:@"网络异常，请求超时"];
        }];
    }else{
        [self doLogin];
        [AppUtils showLoadInfo:@"请登录账号"];
    }
}

- (void)doLogin
{
    UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [HomePageViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
}

- (IBAction)doSearchAction:(id)sender {
    SearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (void)doTapStoreyAction:(NSDictionary *)theStoreyItem {
    if ([[theStoreyItem objectForKey:@"type"] isEqualToString:@"goods"]) {
        OrderWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
        vc.goodsID = [theStoreyItem objectForKey:@"goods"];
        vc.hidesBottomBarWhenPushed = YES;
        [AppUtils pushPage:self targetVC:vc];
    }
    else if ([[theStoreyItem objectForKey:@"type"] isEqualToString:@"active"]) {
        [self handleActivityJump:[theStoreyItem objectForKey:@"url"]];
    }
}

- (void)handleActivityJump:(NSString *)url {
//    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *urlInfo = [CommonTools activityUrlInfo:url];
    // t1商品列表活动展示   t2 秒杀活动  t3 图文
    NSString *activityUrlType = [urlInfo objectForKey:@"activityType"];
    if ([activityUrlType isEqual:@"t1"]) {
        GoodsActivitiesViewController *vc = [[GoodsActivitiesViewController alloc] init];
        vc.url = url;
//        vc.url = @"http://test.m.renrenfenqi.com/spage/other/user_credit.html"; //TODO For test
        
        vc.titleString = @"活动";
        [AppUtils pushPage:self targetVC:vc];
    }else{
//        CommonWebViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
//        vc.url = url;
//        vc.titleString = @"活动";
//        [AppUtils pushPage:self targetVC:vc];
        
        GoodsActivitiesViewController *vc = [[GoodsActivitiesViewController alloc] init];
        vc.url = url;
        vc.titleString = @"活动";
        [AppUtils pushPage:self targetVC:vc];
    }
}

- (void)doDownloadWebAsset:(NSString *)zipUrl newZipVersion:(NSString *)newZipVersion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:zipUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *zipPath = [filePath path];
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSError *zipError = nil;
        BOOL ok = [SSZipArchive unzipFileAtPath:zipPath toDestination:documentsDirectory overwrite:YES password:nil error:&zipError];
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&zipError];
        
        if (ok) {
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [app.store putString:newZipVersion withId:HTML5_ZIP_VERSION intoTable:CFG_TABLE];
        }
        
    }];
    [downloadTask resume];
}

- (IBAction)doLeftItemAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    NSDictionary *theStorey = [_storeyArr objectAtIndex:[btn.titleLabel.text intValue]];
    NSArray *storeyItemArr = [theStorey objectForKey:@"list"];

    if (storeyItemArr.count > 0) {
        [self doTapStoreyAction:storeyItemArr[0]];
    }
}

- (IBAction)doRightItemAction:(id)sender {
    UIButton *btn = (UIButton *)sender;

    NSDictionary *theStorey = [_storeyArr objectAtIndex:[btn.titleLabel.text intValue]];
    NSArray *storeyItemArr = [theStorey objectForKey:@"list"];
    
    if (storeyItemArr.count > 1) {
        [self doTapStoreyAction:storeyItemArr[1]];
    }
}

- (IBAction)doRight2ItemAction:(id)sender {
    UIButton *btn = (UIButton *)sender;

    NSDictionary *theStorey = [_storeyArr objectAtIndex:[btn.titleLabel.text intValue]];
    NSArray *storeyItemArr = [theStorey objectForKey:@"list"];
    
    if (storeyItemArr.count > 2) {
        [self doTapStoreyAction:storeyItemArr[2]];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
    if (self.updateResult) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.updateResult objectForKey:@"path"]]];
    }
}

#pragma -mark HomepageFunctionTableViewCell
-(void)clickLeftButton
{
    
}

-(void)clickMiddleButton
{
    CreditAccountViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditAccountIdentifier"];
    vc.hidesBottomBarWhenPushed = YES;
    [AppUtils pushPage:self targetVC:vc];
}

-(void)clickRightButton
{
    RFPartJobViewController *rfPartJobVC = [[RFPartJobViewController alloc] init];
    rfPartJobVC.hidesBottomBarWhenPushed = YES;
    [AppUtils pushPage:self targetVC:rfPartJobVC];
}
@end
