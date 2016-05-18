//
//  GoodsDetailSpecViewController.m
//  renrenfenqi
//
//  Created by coco on 15-1-15.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "GoodsDetailSpecViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "GoodsDetailsConfigViewController.h"
#import "ActionSheetStringPicker.h"
#import "GoodsRatesViewController.h"
#import "OrderConfirmViewController.h"
#import "UserLoginViewController.h"
#import "GFPlaceholderView.h"

@interface GoodsDetailSpecViewController ()
{
    NSDictionary *_goodsDetail;
    NSDictionary *_accountInfo;
    BOOL _nodata;
    BOOL _isValidUser;
    
    float _viewWidth;
    float _viewHeight;
    
    float _cellHeightArr[12];
    NSArray *_cellIDArr;
    
    NSString *_attrValList;
    float _goodsPrice;
    float _monthPrice;
    float _credit;
    float _needPayMoney;
    
    Class _pushedClass;     //存储 push到哪个VC
    
    NSString *_goodsName;
    NSMutableArray *_goods_first_pay;
    NSString *_goodsID_SKU; //带属性的goodsid
    
    NSMutableDictionary *_allproperty;
    NSString *_ownedSKUStr;
    
    UIButton *_btnFirstPayment;
    UILabel *_lblFirstPayment;
    NSMutableArray *_firstPaymentDataArr;
    float _firstPaymentRatio;
    float _theTop;
    float _theLeft;
    int _fenqiNum;
    
    float _specHeight;
    
    int _rowCount;
    
    NSMutableArray *_ratesArr;
    int _ratesTotal;
    
    NSMutableDictionary *_job;      //兼职选项
    int _selectJob;
    
    BOOL _isHaveSpec;
    BOOL _isHaveImages;
    
    BOOL _isFenqiChanged;
    
    BOOL _isJobBuy;
}

@end

@implementation GoodsDetailSpecViewController

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
    
    _rowCount += _ratesArr.count;
}

- (void)getGoodsRatesFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
//    [AppUtils showLoadInfo:@"加载中"];
    [AppUtils showLoadIng];
    self.btnQuickBuy.hidden = YES;
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", 1]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, RATELIST] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
//        [placeholder hide];
//        [placeholder showViewWithTitle:@"无商品" andSubtitle:@"无商品信息"];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [self handleRatesData:[jsonData objectForKey:@"data"]];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
        if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
            [self getGoodsDetailFromAPINOLogin];
        }
        else
        {
            [self getUserCreditFromAPI];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
//        [placeholder showViewWithTitle:@"无商品" andSubtitle:@"无商品信息"];
        [AppUtils hideLoadIng];
    }];
}

- (void)getGoodsDetailFromAPINOLogin
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = nil;
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL_SPEC_NOLOGIN] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        _nodata = NO;
        [AppUtils hideLoadIng];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _goodsDetail = [jsonData objectForKey:@"data"];
            
            if ([[_goodsDetail objectForKey:@"available"] isEqualToString:@"1"]) {
                self.btnQuickBuy.enabled = YES;
                self.btnQuickBuy.alpha = 1.0;
            }
            
            if (!_isValidUser) {
                _credit = [[_goodsDetail objectForKey:@"default_credit"] floatValue];
            }
            MyLog(@"credit = %0.0f", _credit);
            _isHaveSpec = NO;
            
            [self calcSpecCellHeight];
            [self.tableDetail reloadData];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            UITableViewCell *cell = [self.tableDetail dequeueReusableCellWithIdentifier:_cellIDArr[indexPath.row] forIndexPath:indexPath];
            _isHaveSpec = YES;
            [self initGoodsProperty:cell];
            
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
//            [self.tableDetail beginUpdates];
//            [self.tableDetail reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableDetail endUpdates];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        [AppUtils hideLoadIng];
    }];
}

- (void)getUserCreditFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL_SPEC_LOGIN] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            NSDictionary *result = [jsonData objectForKey:@"data"];
            _credit = [[result objectForKey:@"credit"] floatValue];
            if (_credit < 0) {
                _credit = 0.0;
            }
            _isValidUser = YES;
        }
        
        [self getGoodsDetailFromAPINOLogin];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        [AppUtils hideLoadIng];
    }];
}

- (void)refreshSelectedGoodsInfo
{
    UIButton *btnFirstSelected;
    if (_allproperty.count > 0) {
        NSMutableArray *propertyBtns = [_allproperty objectForKey:@"0"];
        for (UIButton *propertyBtn in propertyBtns) {
            if (propertyBtn.isSelected) {
                btnFirstSelected = propertyBtn;
                break;
            }
        }
    }
    
    if (btnFirstSelected) {
        for (int i = 0; i < 2; i++) {
            [self onPropertyClick:btnFirstSelected];
        }
    }
}

- (void)getUserCreditFromAPIAndUpdateUI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_DETAIL_SPEC_LOGIN] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            NSDictionary *result = [jsonData objectForKey:@"data"];
            _credit = [[result objectForKey:@"credit"] floatValue];
            if (_credit < 0) {
                _credit = 0.0;
            }
            _isValidUser = YES;
        }
        
        //获取用户信用额度后刷新信息
        if (_isValidUser) {
            [self refreshSelectedGoodsInfo];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    [persistentDefaults setObject:@"" forKey:@"LoginGo"];
    self.btnQuickBuy.enabled = NO;
    self.btnQuickBuy.alpha = 0.5;
    
    _nodata = YES;
    _isValidUser = NO;
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _ratesArr = [NSMutableArray array];
    _goods_first_pay = [NSMutableArray array];
    
    _rowCount = 10;
    _cellHeightArr[0] = _viewWidth + 10.0;
    _cellHeightArr[1] = 75.0;
    _cellHeightArr[2] = 75.0;
    _cellHeightArr[3] = 10.0;
    _cellHeightArr[4] = 60.0;
    _cellHeightArr[5] = 10.0;
    _cellHeightArr[6] = 43.0;
    _cellHeightArr[7] = 43.0;
    _cellHeightArr[8] = 10.0;
    _cellHeightArr[9] = 43.0;
    _cellHeightArr[10] = 43.0;
    _cellHeightArr[11] = 43.0;
    
    _theTop = 60.0;
    
    _cellIDArr = @[@"ImagesIdentifier", @"NameIdentifier", @"PriceIdentifier", @"SeparatorIdentifier", @"SpecIdentifier",@"SeparatorIdentifier", @"DetailIdentifier", @"DetailIdentifier", @"SeparatorIdentifier", @"RateTitleIdentifier", @"RateContentIdentifier", @"RateContentIdentifier"];
    
    _firstPaymentDataArr = [NSMutableArray array];
    _firstPaymentRatio = 0.0;
    
    _selectJob = 0;
    
    self.tableDetail.dataSource = self;
    self.tableDetail.delegate = self;
    self.tableDetail.tableFooterView = [UIView new];
    if ([self.tableDetail respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableDetail setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableDetail respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableDetail setLayoutMargins:UIEdgeInsetsZero];
    }
    
    UIView *lineView = [AppUtils makeLine:self.view.bounds.size.width theTop:self.view.bounds.size.height - 49.0];
    [self.view addSubview:lineView];
    
    //TODO test loader
//    UIViewController *appRootVC = [AppUtils topMostController];
//    placeholder = (GFPlaceholderView *)[appRootVC.view viewWithTag:1005];
//    if (!placeholder) {
//        placeholder = [[GFPlaceholderView alloc] initWithFrame:CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 64.0)];
//        placeholder.tag = 1005;
//        [appRootVC.view addSubview:placeholder];
//    }
//    [placeholder showLoadingView];
    
    [self getGoodsRatesFromAPI];
    MyLog(@"goodsid = %@", self.goodsID);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doLogin
{
    UserLoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
    vc.writeInfoMode = WriteInfoModeOption;
    vc.parentClass = [GoodsDetailSpecViewController class];
    _pushedClass = [UserLoginViewController class];
    [AppUtils pushPageFromBottomToTop:self targetVC:vc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MobClick beginLogPageView:TAG];
    
    _accountInfo = [AppUtils getUserInfo];
    if (_pushedClass && (_pushedClass == [UserLoginViewController class])) {
        [self getUserCreditFromAPIAndUpdateUI];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [MobClick endLogPageView:TAG];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.btnQuickBuy.hidden = NO;
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

    if (indexPath.row == 6) {
        GoodsDetailsConfigViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailsConfigIdentifier"];
        vc.htmlStr = [_goodsDetail objectForKey:@"description"];
        vc.isDetail = YES;
        _pushedClass = [GoodsDetailsConfigViewController class];
        [AppUtils pushPage:self targetVC:vc];
    }
    else if (indexPath.row == 7)
    {
        if (![[_goodsDetail objectForKey:@"configure"] isEqualToString:@""]) {
            GoodsDetailsConfigViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailsConfigIdentifier"];
            vc.htmlStr = [_goodsDetail objectForKey:@"configure"];
            vc.isDetail = NO;
            _pushedClass = [GoodsDetailsConfigViewController class];
            [AppUtils pushPage:self targetVC:vc];
        }
        else
        {
            [AppUtils showInfo:@"暂无配置参数！"];
        }
    }
    else if (indexPath.row == 9)
    {
        GoodsRatesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsRatesIdentifier"];
        vc.goodsID = self.goodsID;
        _pushedClass = [GoodsRatesViewController class];
        [AppUtils pushPage:self targetVC:vc];
    }
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        return  _specHeight;
    }
    else
    {
        return _cellHeightArr[indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
//    return _categoryArr.count;
    if (_nodata) {
        return 0;
    }
    else
    {
        return _rowCount;
    }
}

- (void)updateButtonState:(UIButton *)btn
{
    if (btn.isEnabled)
    {
        [btn.layer setBorderColor:[GENERAL_COLOR_GRAY CGColor]];
        [btn.layer setBorderWidth:0.5];
    }
    else
    {
        [btn.layer setBorderColor:[GENERAL_COLOR_GRAY CGColor]];
        [btn.layer setBorderWidth:0.0];
    }
    
    if (btn.selected) {
        [btn.layer setBorderColor:[GENERAL_COLOR_RED CGColor]];
        [btn.layer setBorderWidth:0.5];
    }
}

- (UIButton *)makeAttrButton:(int)j attrItem:(id)attrItem theProperty:(NSMutableArray *)theProperty theCell:(UITableViewCell *)cell
{
    UIButton *btnColor;
    btnColor = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnColor setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
    btnColor.titleLabel.font = GENERAL_FONT13;
    [btnColor setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnColor setTitleColor:GENERAL_COLOR_RED forState:UIControlStateSelected];
    [btnColor setTitleColor:GENERAL_COLOR_RED forState:UIControlStateHighlighted];
    [btnColor setTitleColor:GENERAL_COLOR_GRAY forState:UIControlStateDisabled];
    [btnColor addTarget:self action:@selector(onPropertyClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnColor setTag:j];
    
    [self updateButtonState:btnColor];
    
    CGSize titleSize = [attrItem sizeWithFont:btnColor.titleLabel.font];
    
    titleSize.height = 30;
    titleSize.width += 20;
    
    if (_theLeft + titleSize.width >= (_viewWidth - 10.0)) {
        _theTop += 40.0;
        _theLeft = 60.0;
    }
    
    [btnColor setFrame:CGRectMake(_theLeft, _theTop, titleSize.width, titleSize.height)];
    [btnColor setTitle:attrItem forState:UIControlStateNormal];
    
    [cell addSubview:btnColor];
    [theProperty addObject:btnColor];
    
    _theLeft += titleSize.width + 10.0;
    return btnColor;
}

- (void)makeFirstPaymentRange:(NSArray *)allRatio isJobBuy:(BOOL)isJobBuy
{
//    NSArray *allRatio = @[@"0%", @"10%", @"20%", @"30%", @"40%", @"50%", @"60%", @"70%", @"80%", @"90%", @"100%"];
    
    if (_goodsPrice > _credit) {
        float theRemainMoney = (_goodsPrice - _selectJob * 100) - _credit;
        NSString *theMinRatio = [NSString stringWithFormat:@"%d%%", (int)ceil((theRemainMoney / (_goodsPrice - _selectJob * 100) * 10)) * 10];
        MyLog(@"min ratio = %@, theRemainMoney = %0.0f, theMoney = %0.0f, credit = %0.0f", theMinRatio, theRemainMoney, _goodsPrice - _selectJob * 100, _credit);
        
        [_firstPaymentDataArr removeAllObjects];
        BOOL isRightRatio = NO;
        for (id ratioItem in allRatio) {
//            if ([ratioItem isEqualToString:theMinRatio]) {
//                isRightRatio = YES;
//            }
            if ([[ratioItem stringByReplacingOccurrencesOfString:@"%%" withString:@""] intValue] >= [[theMinRatio stringByReplacingOccurrencesOfString:@"%%" withString:@""] intValue]) {
                isRightRatio = YES;
            }

            if (isRightRatio) {
                if (isJobBuy && ([ratioItem isEqualToString:@"100%"])) {
                    //do nothing
                }
                else
                {
                    [_firstPaymentDataArr addObject:ratioItem];
                }
            }
            
        }
    }
    else
    {
        [_firstPaymentDataArr removeAllObjects];
        if (isJobBuy) {
            for (id ratioItem in allRatio) {
                if (![ratioItem isEqualToString:@"100%"] ) {
                    [_firstPaymentDataArr addObject:ratioItem];
                }
            }
        }
        else
        {
            _firstPaymentDataArr = [NSMutableArray arrayWithArray:allRatio];
        }
    }
}

- (void)selectFirstPayment:(NSString *)firstPaymentValue
{
    UIButton* btnFenqiNeedSelected;
    _firstPaymentRatio = [[firstPaymentValue stringByReplacingOccurrencesOfString:@"%%" withString:@""] floatValue] / 100;
    
    if ([firstPaymentValue isEqualToString:@"100%"])
    {
        _fenqiNum = 1;
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", (int)_allproperty.count - 1]];
        for (UIButton *propertyBtn in propertyBtns) {
            if (propertyBtn.isSelected) {
                propertyBtn.selected = NO;
            }
            propertyBtn.enabled = NO;
            [self updateButtonState:propertyBtn];
        }
        
        [_btnFirstPayment setTitle:[NSString stringWithFormat:@"%@首付", firstPaymentValue] forState:UIControlStateNormal];
        
        //商品没有任何属性，选择100%
        NSArray *goodsArr = [_goodsDetail objectForKey:@"goods_list"];
        NSArray *attrsArr = [_goodsDetail objectForKey:@"attributes"];
        if (attrsArr.count == 0 && goodsArr.count == 1) {
            _goodsPrice = [[goodsArr[0] objectForKey:@"goods_price"] floatValue];
            [self updateOrderMoney];
        }

    }
    else
    {
        if ([_btnFirstPayment.titleLabel.text isEqualToString:@"100%首付"]) { //之前选择100%首付现在选择其他比例的情况下
            _fenqiNum = 0;
            NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", (int)_allproperty.count - 1]];
            for (UIButton *propertyBtn in propertyBtns) {
                propertyBtn.enabled = YES;
                [self updateButtonState:propertyBtn];
                
                if ([propertyBtn isEqual:propertyBtns.lastObject]) {
                    btnFenqiNeedSelected = propertyBtn;
                }
            }
        }
        
        if ([firstPaymentValue isEqualToString:@"0%"]) {
            [_btnFirstPayment setTitle:@"零首付" forState:UIControlStateNormal];
        }
        else
        {
            [_btnFirstPayment setTitle:[NSString stringWithFormat:@"%@首付", firstPaymentValue] forState:UIControlStateNormal];
        }
        
        if (btnFenqiNeedSelected) {
            [self onPropertyClick:btnFenqiNeedSelected];
        }
        
    }

    [self refreshSelectedGoodsInfo];
}

- (void)updateOrderMoneyUI
{
    //update cell
    NSIndexPath *namePath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableDetail beginUpdates];
    [self.tableDetail reloadRowsAtIndexPaths:@[namePath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableDetail endUpdates];
}

- (void)updateOrderMoney
{
    float theGoodsPrice = _goodsPrice;
    
    if (_firstPaymentRatio >= 1.0) {
        _job = nil;
        _fenqiNum = 1;
    }
    
    if (_isJobBuy) {
        int min = [[_job objectForKey:@"min"] intValue] / 100;
        int max = [[_job objectForKey:@"max"] intValue] / 100;
        int defaultDays = [[_job objectForKey:@"default"] intValue] / 100;
        
        if (_isFenqiChanged) {
            _selectJob = defaultDays;
            _isFenqiChanged = NO;
        }
        
        if (_selectJob > 0)
        {
            if ( !((_selectJob >= min) && (_selectJob <= max)) ) {
                _selectJob = defaultDays;
            }
        }
        
        theGoodsPrice = theGoodsPrice - _selectJob * 100;
        
    }
    else
    {
        _selectJob = 0;
    }
    
    float firstPaymentMoney = theGoodsPrice * _firstPaymentRatio;
    _lblFirstPayment.text = [NSString stringWithFormat:@"¥ %0.2f", firstPaymentMoney];
    
    _needPayMoney = theGoodsPrice - firstPaymentMoney;
    float fenqiPrice = _needPayMoney / _fenqiNum;
    if (_fenqiNum == 0) {
        fenqiPrice = 0.0;
    }
    
    MyLog(@"_fenqiNum = %d", _fenqiNum);
    _monthPrice = fenqiPrice;
    
    [self updateOrderMoneyUI];

}

- (BOOL)isInSkustr:(id)propertyValue skustrItems:(NSArray *)skustrItems
{
    BOOL isInSkustr = NO;
    for (id theItem in skustrItems) {
        if ([theItem isEqualToString:propertyValue]) {
            isInSkustr = YES;
            break;
        }
    }
    return isInSkustr;
}

-(BOOL)isInOwnedSKU:(NSArray *)propertyValues
{
    BOOL isIn = NO;
    
    NSArray *SKUArr = [_goodsDetail objectForKey:@"goods_list"];
    for (id skuItem in SKUArr) {
        NSString *skuStr = [skuItem objectForKey:@"attr_val_list"];
        NSArray *skustrItems = [skuStr componentsSeparatedByString:@":"];
        
        int inCount = 0;
        for (id propertyValue in propertyValues) {
            if ( [self isInSkustr:propertyValue skustrItems:skustrItems] ) {
                inCount++;
            }
        }
        
        if (inCount == propertyValues.count) {
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}


- (void)findDisablePropertyWithSelectedButtons:(NSArray *)selectedBtns {
    BOOL isContinue;
    NSMutableArray *propetyStrArr = [NSMutableArray array];
    for (UIButton *btn in selectedBtns) {
        [propetyStrArr addObject:btn.titleLabel.text];
    }
    
    for (int i = 0; i < _allproperty.count - 1; i++) {
        isContinue = NO;
        for (UIButton *btn in selectedBtns) {
            if (i == btn.tag) {
                isContinue = YES;
                break;
            }
        }
        
        if (isContinue) {
            continue;
        }
    
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            NSMutableArray *propetyArrTemp = [NSMutableArray array];
            [propetyArrTemp addObjectsFromArray:propetyStrArr];
            [propetyArrTemp addObject:propetyBtn.titleLabel.text];
            if (![self isInOwnedSKU:propetyArrTemp]) {
                propetyBtn.enabled = NO;
            }
        }
        
    }
}

- (void)onPropertyClick:(id)sender
{
    //初始化
    _isFenqiChanged = NO;
    int i = 0;
    for (i = 0; i < _allproperty.count - 1; i++) {
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            propetyBtn.enabled = YES;
        }
    }
    
    NSMutableArray *selectedPropertyBtns = [NSMutableArray array];
    UIButton *btn = (UIButton*)sender;
    
    NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", (int)btn.tag]];
    for (UIButton *propetyBtn in propertyBtns) {
        if (btn != propetyBtn) {
            [propetyBtn setSelected:NO];
            [self updateButtonState:propetyBtn];
        }
    }
    
    [btn setSelected:(!btn.selected)];
    [self updateButtonState:btn];
    
    //    _fenqiDesc.text = @"请选择您要的商品信息";
    _attrValList = @"";
    
    
    //计算商品价格
    int selectedItemCount = 0;
    NSString *selectedStr = @"";
    //    int i = 0;
    for (i = 0; i < _allproperty.count - 1; i++) {
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            if (propetyBtn.isSelected) {
                [selectedPropertyBtns addObject:propetyBtn];
                if (selectedItemCount == 0) {
                    selectedStr = propetyBtn.titleLabel.text;
                }else{
                    selectedStr = [NSString stringWithFormat:@"%@:%@", selectedStr, propetyBtn.titleLabel.text];
                }
                selectedItemCount++;
                break;
            }
        }
    }
    
    [self findDisablePropertyWithSelectedButtons:selectedPropertyBtns];
    
    for (UIButton *btn in selectedPropertyBtns) {
        NSMutableArray *selectedPropertyBtnsAfterRemoveOne = [NSMutableArray array];
        for (UIButton *theBtn in selectedPropertyBtns) {
            if (![theBtn isEqual:btn]) {
                [selectedPropertyBtnsAfterRemoveOne addObject:theBtn];
            }
        }
        
        [self findDisablePropertyWithSelectedButtons:selectedPropertyBtnsAfterRemoveOne];
    }
    
//    self.lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥ %@", @"0"];
    _goodsPrice = 0.0;
    _fenqiNum = 0;
    _job = nil;
    NSArray *fenqiPriceArr;
    NSArray *fenqiJobsArr;
    if (selectedItemCount == _allproperty.count - 1) {
        NSArray *priceArr = [_goodsDetail objectForKey:@"goods_list"];
        for (id priceItem in priceArr) {
            if ([selectedStr isEqualToString:[priceItem objectForKey:@"attr_val_list"]]) {
                _goodsPrice = [[priceItem objectForKey:@"goods_price"] floatValue];
                _goodsName = [priceItem objectForKey:@"goods_name"];
                _goods_first_pay = [priceItem objectForKey:@"first_pay"];
                _isJobBuy = [[priceItem objectForKey:@"is_job"] isEqualToString:@"0"] ? NO : YES;   //是否兼职购
                
                NSMutableArray *firstPayRatioArr = [NSMutableArray array];
                for (id item in _goods_first_pay) {
                    [firstPayRatioArr addObject:[NSString stringWithFormat:@"%@%%", item]];
                }
                MyLog(@"isJobBuy = %@,", _isJobBuy ? @"YES" : @"NO");
                [self makeFirstPaymentRange:firstPayRatioArr isJobBuy:_isJobBuy];
                
                if (_firstPaymentDataArr.count > 0) {
                    float theMinRatio = [[[_firstPaymentDataArr objectAtIndex:0] stringByReplacingOccurrencesOfString:@"%%" withString:@""] floatValue] / 100;
                    if (theMinRatio > _firstPaymentRatio) {
                        [self selectFirstPayment:[_firstPaymentDataArr objectAtIndex:0]];
                    }
                }
                
                fenqiPriceArr = [priceItem objectForKey:@"period_price"];
                fenqiJobsArr = [priceItem objectForKey:@"jobs"];
                MyLog(@"fenqinum = %d, goodsPrice = %.0f", _fenqiNum, _goodsPrice);
                _attrValList = [priceItem objectForKey:@"attr_val_list"];
                _goodsID_SKU = [priceItem objectForKey:@"goods_id"];
                break;
            }
        }
        
        //fenqi
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            if (propetyBtn.isSelected) {
                
                if (_fenqiNum != [propetyBtn.titleLabel.text intValue]) {
                    _isFenqiChanged = YES;
                }
                _fenqiNum = [propetyBtn.titleLabel.text intValue];

                
                for (id theItem in fenqiPriceArr) {
                    if ([[theItem objectForKey:@"period"] intValue] == _fenqiNum) {
                        _goodsPrice = [[theItem objectForKey:@"price"] floatValue];
                        break;
                    }
                }
                

                for (id theItem in fenqiJobsArr) {
                    if ([[theItem objectForKey:@"period"] intValue] == _fenqiNum) {
                        _job = theItem;
                        break;
                    }
                }
                
                MyLog(@"fenqinum = %d, credit = %0.0f", _fenqiNum, _credit);
                [self updateOrderMoney];
                
                break;
            }
        }
        
        if (_firstPaymentRatio >= 1.0) {
            
            if (_isJobBuy) {
                if (_firstPaymentDataArr.count > 0) {
                    [self selectFirstPayment:[_firstPaymentDataArr objectAtIndex:(_firstPaymentDataArr.count - 1)]];
                }
                else
                {
                    [self selectFirstPayment:@"0%"];
                }
            }
            
            [self updateOrderMoney];
        }
        
    }
    
}

- (void)doJobSelect:(id)sender
{
    NSMutableArray *daysArr = [NSMutableArray array];
    if (_isJobBuy) {
        int min = [[_job objectForKey:@"min"] intValue] / 100;
        int max = [[_job objectForKey:@"max"] intValue] / 100;
        [daysArr addObject:@"不兼职"];
        for (int i = min; i <= max; i++) {
            NSString *theDayStr = [NSString stringWithFormat:@"%d天兼职", i];
            [daysArr addObject:theDayStr];
        }
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"选择兼职天数"
                                            rows:daysArr
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           if ([selectedValue isEqualToString:@"不兼职"]) {
                                               _selectJob = 0;
                                           }
                                           else
                                           {
                                               _selectJob = [[selectedValue stringByReplacingOccurrencesOfString:@"天兼职" withString:@""] intValue];
                                           }
                                           MyLog(@"---- %@", selectedValue);
                                
                                           [self updateOrderMoney];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (void)doShowJobTypeInfo:(id)sender
{
    NSString *msg = [NSString stringWithFormat:@"您之前想通过兼职购模式购买此商品时选择的兼职工种为：%@", self.jobType];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"兼职说明" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)refreshFirstPaymentRatio:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:@"选择首付比例"
                                            rows:_firstPaymentDataArr
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self selectFirstPayment:selectedValue];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (void)calcSpecCellHeight
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    _theTop = 35.0;
    
    //各种属性按钮等等
    _allproperty = [NSMutableDictionary dictionary];
    _theTop = _theTop - 20;
    _theLeft = 10;
    
    NSArray *fenqiStrArr = [_goodsDetail objectForKey:@"support_periods"];
    NSMutableArray *fenqiArr = [NSMutableArray array];
    for (id fenqiItem in fenqiStrArr) {
        NSString *fenqiStr = [NSString stringWithFormat:@"%@月", fenqiItem];
        [fenqiArr addObject:fenqiStr];
    }
    NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict3 setValue:@"分期" forKey:@"attr_name"];
    [dict3 setValue:fenqiStrArr forKey:@"attr_value"];
    [dict3 setValue:@"1234" forKey:@"attr_id"];
    
    NSMutableArray *arr = [_goodsDetail objectForKey:@"attributes"];
    int j = 0;
    for (id item in arr) {
        NSMutableArray *theProperty = [NSMutableArray array];
        _theLeft = 60.0;
        NSArray *attrValues = [item objectForKey:@"attr_value"];
        for (id attrItem in attrValues) {
            [self makeAttrButton:j attrItem:attrItem theProperty:theProperty theCell:cell];
        }
        
        _theTop += 40.0;
        [_allproperty setObject:theProperty forKey:[NSString stringWithFormat:@"%d", j]];
        j++;
    }
    
    //分期
    {
        _theTop += 40.0;
    }
    
    {   //首付
        _theTop += 40.0;
    }
    
    _specHeight = _theTop;
}

- (void)initGoodsProperty:(UITableViewCell *)cell
{
    MyLog(@"hello");
    _theTop = 35.0;
    
    //all SKU String
    NSString *tmpOwnedSKUStr = @"";
    NSArray *ownedSKUItems = [_goodsDetail objectForKey:@"goods_list"];
    for (id itemPrice in ownedSKUItems) {
        if ([tmpOwnedSKUStr isEqualToString:@""]) {
            tmpOwnedSKUStr = [itemPrice objectForKey:@"attr_val_list"];
        } else {
            tmpOwnedSKUStr = [NSString stringWithFormat:@"%@:%@", tmpOwnedSKUStr, [itemPrice objectForKey:@"attr_val_list"]];
        }
    }
    NSArray *tmpOwnedSkuItems = [tmpOwnedSKUStr componentsSeparatedByString:@":"];
    NSSet *ownedSkuSets = [NSSet setWithArray:tmpOwnedSkuItems];
    
    NSArray *firstSKU = [[ownedSKUItems.firstObject objectForKey:@"attr_val_list"] componentsSeparatedByString:@":"];
    
    //各种属性按钮等等
    _allproperty = [NSMutableDictionary dictionary];
    _theTop = _theTop - 20;
    _theLeft = 10;
    
    _job = [NSMutableDictionary dictionary];
    
    NSArray *fenqiStrArr = [_goodsDetail objectForKey:@"support_periods"];
    NSMutableArray *fenqiArr = [NSMutableArray array];
    for (id fenqiItem in fenqiStrArr) {
        NSString *fenqiStr = [NSString stringWithFormat:@"%@月", fenqiItem];
        [fenqiArr addObject:fenqiStr];
    }
    NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict3 setValue:@"分期" forKey:@"attr_name"];
    [dict3 setValue:fenqiStrArr forKey:@"attr_value"];
    [dict3 setValue:@"1234" forKey:@"attr_id"];
    
    NSMutableArray *arr = [_goodsDetail objectForKey:@"attributes"];
    int j = 0;
    int k = 0;  //firstSKU's index
    for (id item in arr) {
        //        _theTop = _theTop + theVSpace;
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = [NSString stringWithFormat:@"%@:", [item objectForKey:@"attr_name"]];
        [cell addSubview:lblProperty];
        
        NSMutableArray *theProperty = [NSMutableArray array];
        _theLeft = 60.0;
        NSArray *attrValues = [item objectForKey:@"attr_value"];
        int i = 0;
        for (id attrItem in attrValues) {
            //TODO
//            NSRange isRange = [_ownedSKUStr rangeOfString:attrItem options:NSCaseInsensitiveSearch];
            if (![ownedSkuSets containsObject:attrItem]) {
                continue;
            }
            
            UIButton *btnColor = [self makeAttrButton:j attrItem:attrItem theProperty:theProperty theCell:cell];
            
            if (k < firstSKU.count) {   //选中第一种商品
                if ([attrItem isEqualToString:[firstSKU objectAtIndex:k]])
                {
                    btnColor.selected = YES;
                    [self updateButtonState:btnColor];
                    k++;
                }
            }
            
            i++;
        }
        
        _theTop += 40.0;
        [_allproperty setObject:theProperty forKey:[NSString stringWithFormat:@"%d", j]];
        j++;
    }
    
    UIButton *defaultFenqiBtn = nil;
    {
        id item = dict3;
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = [NSString stringWithFormat:@"%@:", [item objectForKey:@"attr_name"]];
        [cell addSubview:lblProperty];
        
        NSMutableArray *theProperty = [NSMutableArray array];
        _theLeft = 60.0;
        NSArray *attrValues = [item objectForKey:@"attr_value"];
        int i = 0;
        for (id attrItem in attrValues) {
            UIButton *btnAttr = [self makeAttrButton:j attrItem:attrItem theProperty:theProperty theCell:cell];
            if (i == attrValues.count - 1) {
                defaultFenqiBtn = btnAttr;
            }
            
            i++;
        }
        
        _theTop += 40.0;
        [_allproperty setObject:theProperty forKey:[NSString stringWithFormat:@"%d", j]];
        j++;
    }
    
    {   //首付
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop + 3, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = @"首付：";
        [cell addSubview:lblProperty];
        
        _btnFirstPayment = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFirstPayment setBackgroundImage:[UIImage imageNamed:@"specifications_body_backgroud_d"] forState:UIControlStateNormal];
        _btnFirstPayment.frame = CGRectMake(60.0, _theTop, 71.0, 31.0);
        _btnFirstPayment.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        [_btnFirstPayment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnFirstPayment setTitle:@"零首付" forState:UIControlStateNormal];
        _btnFirstPayment.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_btnFirstPayment addTarget:self action:@selector(refreshFirstPaymentRatio:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:_btnFirstPayment];
        
        _lblFirstPayment = [[UILabel alloc] initWithFrame:CGRectMake(141.0, _theTop + 3, 100.0, 21.0)];
        _lblFirstPayment.font = GENERAL_FONT13;
        _lblFirstPayment.text = @"¥ 588.80";
        [cell addSubview:_lblFirstPayment];
        
        _theTop += 40.0;
    }
    
    if (defaultFenqiBtn != nil) {
        [self onPropertyClick:defaultFenqiBtn];
    }
    
    if (_firstPaymentDataArr.count > 0) {
        [self selectFirstPayment:[_firstPaymentDataArr objectAtIndex:0]];
    }
    
    if (_isJobBuy) {
        _selectJob = [[_job objectForKey:@"default"] intValue] / 100;
        
        [self updateOrderMoney];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIDArr[indexPath.row] forIndexPath:indexPath];
    
    MyLog(@"cellForRowAtIndexPath %d", (int)indexPath.row);
    
    switch (indexPath.row) {
        case 0:
        {
            if (![cell viewWithTag:1]) {
                NSMutableArray *urlArr = [_goodsDetail objectForKey:@"images"];
                if (urlArr.count > 0) {
                    NSMutableArray *imagesArr = [NSMutableArray array];
                    for (id urlItem in urlArr) {
                        NSString *theUrl = (NSString *)urlItem;
                        SGFocusImageItem *item1 = [[SGFocusImageItem alloc] initWithTitle:@"title1" image:nil tag:0 url:theUrl];
                        [imagesArr addObject:item1];
                    }
                    
                    SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0.0, 0.0, _viewWidth, _viewWidth)
                                                                                    delegate:self
                                                                       focusImageItemsArrray:imagesArr
                                                               currentPageIndicatorTintColor:[UIColor colorWithRed:244/255.0 green:78/255.0 blue:78/255.0 alpha:1.0]];
                    imageFrame.autoScrolling = NO;
                    imageFrame.tag = 1;
                    [cell addSubview:imageFrame];
                }
                
//                _isHaveImages = YES;
            }
        }
            break;
        case 1:
        {
            UILabel *lblName = (UILabel *)[cell viewWithTag:1];
//            lblName.text = [_goodsDetail objectForKey:@"goods_map_name"];
            lblName.text = _goodsName;
        }
            break;
        case 2:
        {
            UILabel *lblPrice = (UILabel *)[cell viewWithTag:1];
            UIButton *btnJobDaysSelect = (UIButton *)[cell viewWithTag:2];
            UILabel *lblMonthPayment = (UILabel *)[cell viewWithTag:3];
            UIButton *btnJobTypeInfo = (UIButton *)[cell viewWithTag:4];
            
            [btnJobDaysSelect addTarget:self action:@selector(doJobSelect:) forControlEvents:UIControlEventTouchUpInside];
            [btnJobTypeInfo addTarget:self action:@selector(doShowJobTypeInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            if (_isJobBuy) {
                btnJobDaysSelect.hidden = NO;
                btnJobTypeInfo.hidden = NO;
                if (_selectJob == 0) {
                    [btnJobDaysSelect setTitle:@"不兼职" forState:UIControlStateNormal];
                }
                else if(_selectJob > 0)
                {
                    [btnJobDaysSelect setTitle:[NSString stringWithFormat:@"%d天兼职", _selectJob] forState:UIControlStateNormal];
                }
                
                if (!self.jobType) {
                    btnJobTypeInfo.hidden = YES;
                }
            }
            else
            {
                btnJobDaysSelect.hidden = YES;
                btnJobTypeInfo.hidden = YES;
            }
            
            
            
            lblPrice.text = [NSString stringWithFormat:@"¥ %0.0f", _goodsPrice - _selectJob * 100];
            if (!btnJobDaysSelect.isHidden) {
                lblPrice.text = [NSString stringWithFormat:@"%@%@", lblPrice.text, @"  +"];
            }
            lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥ %.2f X %d期", _monthPrice, _fenqiNum];
            
            if ([[AppUtils iosVersion] floatValue] >= 7.0 && lblMonthPayment.text) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lblMonthPayment.text];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:GENERAL_COLOR_RED
                                         range:NSMakeRange(3, [NSString stringWithFormat:@"¥ %.2f", _monthPrice].length)];
                
                [attributedString addAttribute:NSFontAttributeName
                                         value:GENERAL_FONT18   //[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]
                                         range:NSMakeRange(3, [NSString stringWithFormat:@"¥ %.2f", _monthPrice].length)];
                
                lblMonthPayment.attributedText = attributedString;
            }
            
        }
            break;
        case 4:
        {
//            //TODO
//            if ((!_isHaveSpec) && _goodsDetail) {
//                _isHaveSpec = YES;
//                [self initGoodsProperty:cell];
//                MyLog(@"aAAAAAA");
//            }
        }
            break;
        case 7:
        {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:1];
            lblTitle.text = @"配置参数";
        }
            break;
        case 9:
        {
            UILabel *lblRateCount = (UILabel *)[cell viewWithTag:1];
            lblRateCount.text = [NSString stringWithFormat:@"(%d人评价)", _ratesTotal];
        }
            break;
        case 10:
        case 11:
        {
            NSDictionary *theRate = [_ratesArr objectAtIndex:indexPath.row - 10];
            
            UIImageView *cellRateStar = (UIImageView *)[cell viewWithTag:1];
            UILabel *cellName = (UILabel *)[cell viewWithTag:2];
            UILabel *cellContent = (UILabel *)[cell viewWithTag:3];
            
            NSString *starName = [self makeStarStr:[[theRate objectForKey:@"star"] intValue]];
            [cellRateStar setImage:[UIImage imageNamed:starName]];
            cellName.text = [NSString stringWithFormat:@"%@", [theRate objectForKey:@"time"]];
            cellContent.text = [theRate objectForKey:@"content"];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark -
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if (item.tag == 1004) {
        [imageFrame removeFromSuperview];
    }
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

- (IBAction)doQuickBuyAction:(id)sender {
    if (!_isValidUser) {
        [self doLogin];
        
        return;
    }
    
    if (_goodsPrice <= 0) {
        [AppUtils showInfo:@"请选择商品"];
        return;
    }
    
    if (_credit < _needPayMoney) {
        [AppUtils showInfo:@"信用额度不足"];
        return;
    }
    
    if (_fenqiNum <= 0) {
        [AppUtils showInfo:@"请选择分期数"];
        return;
    }
    
    OrderConfirmViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmIdentifier"];
    vc.goodsID = _goodsID_SKU;
    vc.goodsName = _goodsName;
    vc.goodsDetail = _goodsDetail;
    vc.goodsPrice = _goodsPrice;
    vc.firstPaymentRatio = _firstPaymentRatio;
    vc.fenqiNum = _fenqiNum;
    vc.jobPrice = _selectJob;
    vc.jobType = self.jobType;
    _pushedClass = [OrderConfirmViewController class];
    [AppUtils pushPage:self targetVC:vc];
}
@end
