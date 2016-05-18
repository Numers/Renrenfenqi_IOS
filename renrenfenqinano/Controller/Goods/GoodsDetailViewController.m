//
//  GoodsDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-13.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "HMSegmentedControl.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "GoodsSpecificationViewController.h"
#import "GoodsRatesViewController.h"
#import "UserLoginViewController.h"

#define TAG_RATE_COUNT 1
#define TAG_RATE_STAR 1
#define TAG_RATE_NAME 2
#define TAG_RATE_CONTENT 3

@interface GoodsDetailViewController ()
{
    NSDictionary *_goodsDetail;
    HMSegmentedControl *_segmentedControl;
    UIWebView *_webView;
    NSDictionary *_accountInfo;
    NSMutableArray *_ratesArr;
    int _ratesTotal;
    float _theTop;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation GoodsDetailViewController

- (void)handleRatesData:(NSDictionary *)result
{
    _ratesTotal = (int)[[result objectForKey:@"total"] floatValue];
    
    NSArray *tempRatesArr = [[result objectForKey:@"list"] mutableCopy];
    if (tempRatesArr.count > 2) {
        for (int i = 0; i < 2; i++) {
            [_ratesArr addObject:[tempRatesArr objectAtIndex:i]];
        }
    }
    else
    {
        _ratesArr = [NSMutableArray arrayWithArray:tempRatesArr];
    }
    
    [self.tableEvaluate reloadData];
}

- (void)getGoodsRatesFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", 1]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, RATELIST] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleRatesData:[jsonData objectForKey:@"data"]];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
        MyLog(@"goodsid = %@", self.goodsID);
        [self getGoodsDetailFromAPI];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)getGoodsDetailFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary* jsonData = [operation.responseString objectFromJSONString];
    MyLog(operation.responseString);
    
    if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
        _goodsDetail = [jsonData objectForKey:@"data"];
    
        [self initUI];
    }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)segmentedControlChangedValue:(id)sender
{
    HMSegmentedControl *theSegmentControl = (HMSegmentedControl*)sender;
    
    switch (theSegmentControl.selectedSegmentIndex) {
        case 0:
        {
            [_webView loadHTMLString:[self preHandleHtml:[_goodsDetail objectForKey:@"description"]] baseURL:nil];
        }
            break;
        case 1:
        {
            [_webView loadHTMLString:[self preHandleHtml:[_goodsDetail objectForKey:@"configure"]] baseURL:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    MyLog(@"hello");
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    if (fittingSize.height > [UIScreen mainScreen].bounds.size.height) {
        [self.scrollView setContentSize:CGSizeMake(320.0f, _theTop + fittingSize.height + 100)];
        self.contentHeightConstraint.constant = _theTop + fittingSize.height + 100;
    }else{
        [self.scrollView setContentSize:CGSizeMake(320.0f, _theTop + fittingSize.height + [UIScreen mainScreen].bounds.size.height - fittingSize.height)];
        self.contentHeightConstraint.constant = _theTop + fittingSize.height + [UIScreen mainScreen].bounds.size.height - fittingSize.height;
    }
}

- (NSString *)preHandleHtml:(NSString *)htmlStr
{
    //    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"style=\"\"" withString:@"style=\"width:100%;\""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p><br/></p>" withString:@""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"style=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"width=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"height=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<img " withString:@"<img style=\"width:100%;\""];
    
    return htmlStr;
}

- (void)initUI
{
    NSMutableArray *urlArr = [_goodsDetail objectForKey:@"images"];
    if (urlArr.count > 0) {
        NSMutableArray *imagesArr = [NSMutableArray array];
        for (id urlItem in urlArr) {
            NSString *theUrl = (NSString *)urlItem;
            SGFocusImageItem *item1 = [[SGFocusImageItem alloc] initWithTitle:@"title1" image:nil tag:0 url:theUrl];
            [imagesArr addObject:item1];
        }
        
        SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:self.imgsView.frame
                                                                        delegate:self
                                                           focusImageItemsArrray:imagesArr
                                                            currentPageIndicatorTintColor:[UIColor colorWithRed:244/255.0 green:78/255.0 blue:78/255.0 alpha:1.0]];
        imageFrame.autoScrolling = NO;
        [self.scrollView addSubview:imageFrame];
    }
    
    self.lblGoodsName.text = [_goodsDetail objectForKey:@"name"];
    self.lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.f", [[_goodsDetail objectForKey:@"price"] floatValue]];
    self.lblMonthPaymentTip.text = [NSString stringWithFormat:@"  ¥%@ X %@期", [_goodsDetail objectForKey:@"month_price"], [_goodsDetail objectForKey:@"period"]];
    if ([[_goodsDetail objectForKey:@"available"] isEqualToString:@"1"]) {
        self.btnBuy.enabled = YES;
    }
    
    _theTop = self.evaluateView.frame.origin.y + self.evaluateView.bounds.size.height;
    if (_ratesTotal == 0) {
        _theTop = self.evaluateView.frame.origin.y + 44.0;
    }
    else if(_ratesTotal == 1)
    {
        _theTop = self.evaluateView.frame.origin.y + 88.0;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, _theTop + 1, _viewWidth, 8.0)];
    line.backgroundColor = GENERAL_COLOR_GRAY2;
    [self.scrollView addSubview:line];
    UIView *line1 = [AppUtils makeLine:_viewWidth theTop:_theTop + 10.0];
    [self.scrollView addSubview:line1];
    
    _theTop += 12.0;
    
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"商品详情", @"配置参数"]];
    _segmentedControl.frame = CGRectMake(0.0, _theTop, _viewWidth, 30);
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    _segmentedControl.font = GENERAL_FONT13;
    _segmentedControl.textColor = [UIColor grayColor];
    _segmentedControl.selectedTextColor = [UIColor colorWithRed:231/255.0 green:88/255.0 blue:69/255.0 alpha:1.0];
    _segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:231/255.0 green:88/255.0 blue:69/255.0 alpha:1.0];
    _segmentedControl.selectionIndicatorHeight = 2.0f;
    _segmentedControl.scrollEnabled = YES;
    [self.scrollView addSubview:_segmentedControl];
    
    _theTop += 30.0;
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _theTop, _viewWidth, 320.0)];
    _webView.scrollView.scrollEnabled = NO;
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [_webView loadHTMLString:[self preHandleHtml:[_goodsDetail objectForKey:@"description"]] baseURL:nil];
    [self.scrollView addSubview:_webView];
    
    self.scrollView.contentSize = CGSizeMake(80, _viewHeight + 500.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    [persistentDefaults setObject:@"" forKey:@"LoginGo"];
    
    _ratesArr = [NSMutableArray array];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    self.btnBuy.enabled = NO;
    
    _goodsDetail = @{
                     @"images":@[@"http://img.renrenfenqi.com/201409/18095243189.jpg@90Q.jpg",
                                 @"http://img.renrenfenqi.com/201410/24105227975.jpg@90Q.jpg",
                                 @"http://img.renrenfenqi.com/201409/18095243189.jpg@90Q.jpg"],
                     @"title":@"三星 iphone 5",
                     @"name":@"白色 64G 三星 iphone",
                     @"price":@"1999",
                     @"month_price":@"888",
                     @"period":@"4",
                     @"description":@"sssssssssssssddddssss",
                     @"configure":@"ss"
                     };
    
    MyLog(@"goodsid = %@", self.goodsID);
    [self getGoodsRatesFromAPI];
//    [self performSelector:@selector(initUI) withObject:nil afterDelay:0.1];
    
    self.tableEvaluate.delegate = self;
    self.tableEvaluate.dataSource = self;
    if ([self.tableEvaluate respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableEvaluate setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableEvaluate respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableEvaluate setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)doLogin
{
    UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [GoodsDetailViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
    _accountInfo = [AppUtils getUserInfo];
    
    if ([[persistentDefaults objectForKey:@"LoginGo"] isEqualToString:@"yes"])
    {
        [persistentDefaults setObject:@"" forKey:@"LoginGo"];
        [self performSelector:@selector(doLogin) withObject:nil afterDelay:0.5];
    }
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
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if (item.tag == 1004) {
        [imageFrame removeFromSuperview];
    }
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
    return 44;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleIdentifier" forIndexPath:indexPath];
        
        UILabel *cellCount = (UILabel *)[cell viewWithTag:TAG_RATE_COUNT];
        cellCount.text = [NSString stringWithFormat:@"评价晒单(%d人评价)", _ratesTotal];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"contentIdentifier" forIndexPath:indexPath];
        
        NSDictionary *theRate = [_ratesArr objectAtIndex:indexPath.row - 1];
        
        UIImageView *cellRateStar = (UIImageView *)[cell viewWithTag:TAG_RATE_STAR];
        UILabel *cellName = (UILabel *)[cell viewWithTag:TAG_RATE_NAME];
        UILabel *cellContent = (UILabel *)[cell viewWithTag:TAG_RATE_CONTENT];
        
        NSString *starName = [self makeStarStr:[[theRate objectForKey:@"star"] intValue]];
        [cellRateStar setImage:[UIImage imageNamed:starName]];
        cellName.text = [NSString stringWithFormat:@"%@", [theRate objectForKey:@"time"]];
        cellContent.text = [theRate objectForKey:@"content"];
    }
    
//    if (indexPath.row == 0 || indexPath.row == 2)
//    {
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, 43.5, 15.0, 0.5)];
//        line.backgroundColor = GENERAL_COLOR_GRAY;
//        [cell addSubview:line];
//    }
    
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
- (void)back
{
    [AppUtils goBack:self];
}

- (IBAction)buyAction:(id)sender {
    if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
        UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
        vc.writeInfoMode = WriteInfoModeOption;
        vc.parentClass = [GoodsDetailViewController class];
        [AppUtils pushPageFromBottomToTop:self targetVC:vc];
        return;
    }
    
    GoodsSpecificationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsSpecificationIdentifier"];
    vc.goodsID = self.goodsID;
    vc.goodsDetail = _goodsDetail;
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)backAction:(id)sender {
    [self back];
}

- (IBAction)moreRatesAction:(id)sender {
    GoodsRatesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsRatesIdentifier"];
    vc.goodsID = self.goodsID;
    [AppUtils pushPage:self targetVC:vc];
}
@end
