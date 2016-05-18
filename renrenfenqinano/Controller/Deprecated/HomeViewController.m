//
//  FirstViewController.m
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "HomeViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "CategoryListViewController.h"
#import "OrderAddressAddViewController.h"
#import "OrderAddressViewController.h"

#import "MyOrdersViewController.h"
#import "OrderConfirmViewController.h"
#import "OrderDetailViewController.h"
#import "OrderEvaluateViewController.h"
#import "UserLoginViewController.h"
#import "OrderDetailViewController.h"
#import "MyBillsViewController.h"
#import "SearchViewController.h"
#import "GoodsDetailViewController.h"
#import "CommonWebViewController.h"
#import "SearchResultViewController.h"
#import "GoodsRatesViewController.h"
#import "AddressSelectViewController.h"
#import "MyBillsAutoRepaymentOKViewController.h"
#import "UserGuideViewController.h"
#import "JobDetailViewController.h"
#import "JobSettingViewController.h"
#import "GoodsDetailSpecViewController.h"

#import "PersonalCenterViewController.h"
#import "AppDelegate.h"
#import "WishViewController.h"
#import "MJRefresh.h"
#import "HomePageViewController.h"

#define CATEGORY_TAG_MIN 3000


@interface HomeViewController ()
{
    NSMutableArray *_adArr;
    NSMutableArray *_hotArr;
    NSMutableArray *_categoryArr;
    
    NSMutableDictionary *_homeDataDict;
    
    float _viewWidth;
    float _viewHeight;
    
    UIRefreshControl *_refreshControl;
    
    float _theTop;
}

@end

@implementation HomeViewController

- (void)doGoCategory:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CategoryListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryListIdentifier"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.categoryName = [_categoryArr[btn.tag - CATEGORY_TAG_MIN] objectForKey:@"cname"];
    [AppUtils pushPage:self targetVC:vc];
}

- (void)makeCategoryButton:(float)theWidth theHeight:(float)theHeight theLeft:(float)theLeft theTop:(float)theTop i:(int)i
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(theLeft, theTop, theWidth, theHeight);
    btn.tag = i + CATEGORY_TAG_MIN;
    [btn addTarget:self action:@selector(doGoCategory:) forControlEvents:UIControlEventTouchUpInside];
    [btn sd_setImageWithURL:[NSURL URLWithString:[_categoryArr[i] objectForKey:@"banner_path"]] forState:UIControlStateNormal];
    [self.contentView addSubview:btn];
}

- (void)doGoHotGoods:(int)index
{
    NSDictionary *theHot = [_hotArr objectAtIndex:index];
    if ([[theHot objectForKey:@"type"] isEqualToString:@"goods"]) {
        GoodsDetailSpecViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailSpecIdentifier"];
        vc.goodsID = [theHot objectForKey:@"goods"];
        vc.hidesBottomBarWhenPushed = YES;
        [AppUtils pushPage:self targetVC:vc];
    }
}

- (void)tapHotGoods:(id)sender {
    UITapGestureRecognizer *ges = (UITapGestureRecognizer *)sender;
    [self doGoHotGoods:(int)ges.view.tag];
}

- (void)initUI
{
    [[self.adView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.hotView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (id viewItem in [self.contentView subviews]) {
        if ( ((UIView *)viewItem).tag >= CATEGORY_TAG_MIN ) {
            [((UIView *)viewItem) removeFromSuperview];
        }
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
        
        SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:self.adView.frame
                                                                        delegate:self
                                                           focusImageItemsArrray:imagesArr];
        imageFrame.autoScrolling = NO;
        [self.adView addSubview:imageFrame];
    }
    
    //hot
    int theHotCount = 0;
    if (_hotArr.count > 3) {
        theHotCount = 3;
    }
    else
    {
        theHotCount = (int)_hotArr.count;
    }

    float hotProductWidth = (self.hotView.frame.size.width - 10.0) / 3.0;
    float theLeft = 0.0;
    for (int i = 0; i < theHotCount; i++) {
        id hotItem = _hotArr[i];
        theLeft = (hotProductWidth + 5.0) * i ;
        UIImageView *imgHot = [[UIImageView alloc] initWithFrame:CGRectMake(theLeft, 0.0, hotProductWidth, hotProductWidth)];
        [imgHot sd_setImageWithURL:[NSURL URLWithString:[hotItem objectForKey:@"img_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHotGoods:)];
        singleTap.numberOfTapsRequired = 1;
        [imgHot setUserInteractionEnabled:YES];
        [imgHot addGestureRecognizer:singleTap];
        imgHot.tag = i;
        [AppUtils makeBorder:imgHot];
        [self.hotView addSubview:imgHot];
        
        UIImageView *imgLbl = [[UIImageView alloc] initWithFrame:CGRectMake(hotProductWidth - 48.0, hotProductWidth - 25.0, 48.0, 14.0)];
        [imgLbl setImage:[UIImage imageNamed:@"home_body_label_n"]];
        [imgHot addSubview:imgLbl];
        
        UILabel *lblMonthPrice = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 40.0, 14.0)];
        lblMonthPrice.textColor = [UIColor whiteColor];
        lblMonthPrice.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:9];
        lblMonthPrice.text = [NSString stringWithFormat:@"¥%0.f每期", [[hotItem objectForKey:@"month_price"] floatValue]];
        lblMonthPrice.textAlignment = NSTextAlignmentRight;
        [imgLbl addSubview:lblMonthPrice];
        
        if ([[AppUtils iosVersion] floatValue] >= 7.0) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lblMonthPrice.text];
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:7]
                                     range:NSMakeRange(lblMonthPrice.text.length - (@"每期").length, (@"每期").length)];
            
            lblMonthPrice.attributedText = attributedString;
        }
    }
    
    //category
    _theTop = self.themeTitle.frame.origin.y + self.themeTitle.frame.size.height + 10.0;
    float theWidth = (_viewWidth - 30.0 - 2.0) * 0.5;
    float theHeight = (_viewWidth - 30.0 - 2.0) * 0.5 / 1.68;
    float theLeft1 = 15.0;
    float theLeft2 = theWidth + 15.0 + 2.0;
    for (int i = 0; i < _categoryArr.count; i++) {
        if (i % 2 == 0) {
            [self makeCategoryButton:theWidth theHeight:theHeight theLeft:theLeft1 theTop:_theTop i:i];
        }
        else
        {
            [self makeCategoryButton:theWidth theHeight:theHeight theLeft:theLeft2 theTop:_theTop i:i];
            _theTop += theHeight + 2.0;
        }
    }

    if (_categoryArr.count % 2 == 1) {
        _theTop += theHeight + 2.0;
    }
    self.contentHeiConstraint.constant = _theTop + 20.0;
    self.scrollView.contentSize = CGSizeMake(80, _theTop + 20.0);
}

- (void)refreshContent
{
//    if (_categoryArr.count <= 0) {
        [self getHomeDataFromAPI];
//    }
//    [_refreshControl endRefreshing];
    [self.scrollView headerEndRefreshing];
}

- (void)getHomeDataFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, HOME_IF2] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
//        [_refreshControl endRefreshing];
        [self.scrollView headerEndRefreshing];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            if (_homeDataDict == nil || (![_homeDataDict isEqualToDictionary:[jsonData objectForKey:@"data"]]))
            {
                MyLog(@"CCCCCCCCCCCCCC");
                
                _homeDataDict = [[jsonData objectForKey:@"data"] mutableCopy];
                [persistentDefaults setObject:[jsonData objectForKey:@"data"] forKey:@"HomeData"];
                _adArr = [_homeDataDict objectForKey:@"banner"];
                _hotArr = [_homeDataDict objectForKey:@"hot"];
                _categoryArr = [_homeDataDict objectForKey:@"category"];
                
                [self performSelector:@selector(initUI) withObject:nil afterDelay:0.2];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_refreshControl endRefreshing];
        [self.scrollView headerEndRefreshing];
    }];
}

- (void)doUserGuide {
    UserGuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserGuideIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
    [persistentDefaults setObject:@"1" forKey:@"isNewbie"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
//    self.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
//    self.scrollView.contentSize = CGSizeMake(80, 1200);
    
//    UIView *theLine = [AppUtils makeLine:self.view.bounds.size.width theTop:43.0];
//    [self.navView addSubview:theLine];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _adArr = [NSMutableArray array];
    _hotArr = [NSMutableArray array];
    _categoryArr = [NSMutableArray array];
    
    _homeDataDict = [NSMutableDictionary dictionary];
    if ([persistentDefaults objectForKey:@"HomeData"]) {
        _homeDataDict = [persistentDefaults objectForKey:@"HomeData"];
        
        _adArr = [_homeDataDict objectForKey:@"banner"];
        _hotArr = [_homeDataDict objectForKey:@"hot"];
        _categoryArr = [_homeDataDict objectForKey:@"category"];
        
        [self performSelector:@selector(initUI) withObject:nil afterDelay:0.2];
    }
    
    [self getHomeDataFromAPI];
    
    if (![persistentDefaults objectForKey:@"isNewbie"]) {
        [self performSelector:@selector(doUserGuide) withObject:nil afterDelay:0.5];
    }

//    _refreshControl = [[UIRefreshControl alloc] init];
//    [_refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
//    [self.scrollView addSubview:_refreshControl];
    
    [self.scrollView addHeaderWithTarget:self action:@selector(refreshContent)];
    self.scrollView.headerPullToRefreshText = @"下拉可以刷新了";
    self.scrollView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.scrollView.headerRefreshingText = @"仁仁分期玩命刷新中";
    
    //TODO
//    [self performSelector:@selector(doTest) withObject:nil afterDelay:0.5];
}

- (void)doTest
{
    //TODO
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

                        
                        HomePageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageIdentifier"];
                        [AppUtils pushPage:self targetVC:vc];

                    }
                    completion:NULL];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
//    self.scrollView.contentSize = CGSizeMake(80, _theTop + 100.0);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [MobClick endLogPageView:TAG];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)doGoAdGoods:(SGFocusImageItem *)item
{
    NSDictionary *theBanner = [_adArr objectAtIndex:item.tag];
    if ([[theBanner objectForKey:@"type"] isEqualToString:@"goods"]) {
        GoodsDetailSpecViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailSpecIdentifier"];
        vc.goodsID = [theBanner objectForKey:@"goods"];
        vc.hidesBottomBarWhenPushed = YES;
        [AppUtils pushPage:self targetVC:vc];
    }
    else if ([[theBanner objectForKey:@"type"] isEqualToString:@"active"])
    {
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        CommonWebViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"CommonWebIdentifier"];
        vc.url = [theBanner objectForKey:@"url"];
        vc.titleString = @"活动";
        vc.hidesBottomBarWhenPushed = YES;
        [AppUtils pushPage:self targetVC:vc];
    }
}

- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if (item.tag == 1004) {
        [imageFrame removeFromSuperview];
    }
    
    [self doGoAdGoods:item];
}

- (IBAction)doGoSearch:(id)sender {
    SearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}
@end
