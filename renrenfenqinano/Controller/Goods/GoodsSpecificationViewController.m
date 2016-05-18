//
//  GoodsSpecificationViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "GoodsSpecificationViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "ActionSheetStringPicker.h"
#import "OrderConfirmViewController.h"
#import "UserLoginViewController.h"


@interface GoodsSpecificationViewController ()
{
    NSDictionary *_goodsSpec;
    NSDictionary *_accountInfo;
    
    NSMutableArray *_firstPaymentDataArr;
    
    NSString *_goodsID_SKU; //带属性的goodsid
    
    NSString *_attrValList;
    float _goodsPrice;
    float _credit;
    float _needPayMoney;
    float _firstPaymentRatio;
    
    NSMutableDictionary *_allproperty;
    NSString *_ownedSKUStr;
    int _fenqiNum;
    
    UIButton *_btnFirstPayment;
    UILabel *_lblFirstPayment;
    
    float _viewWidth;
    float _viewHeight;
    float _theTop;
    float _theLeft;
}

@end

@implementation GoodsSpecificationViewController

- (void)getGoodsSpecFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    [AppUtils showLoadIng];
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", SECURE_BASE, GOODS_SPEC] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        [AppUtils hideLoadIng];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _goodsSpec = [jsonData objectForKey:@"data"];
            _credit = [[_goodsSpec objectForKey:@"credit"] floatValue];
            
            [self initGoodsProperty];
        }
        else if ([@"-1" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]])
        {
            [AppUtils showInfo:STR_LOGIN_TIMEOUT];
            
            [persistentDefaults setObject:@"yes" forKey:@"LoginGo"];
            [self doBackAction:self];
            
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils hideLoadIng];
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)makeFirstPaymentRange
{
    NSArray *allRatio = @[@"0%", @"10%", @"20%", @"30%", @"40%", @"50%", @"60%", @"70%", @"80%", @"90%", @"100%"];
    
    if (_goodsPrice > _credit) {
        float theRemainMoney = _goodsPrice - _credit;
        NSString *theMinRatio = [NSString stringWithFormat:@"%d%%", (int)ceil((theRemainMoney / _goodsPrice * 10)) * 10];
        
        [_firstPaymentDataArr removeAllObjects];
        BOOL isRightRatio = NO;
        for (id ratioItem in allRatio) {
            if ([ratioItem isEqualToString:theMinRatio]) {
                isRightRatio = YES;
            }
            
            if (isRightRatio) {
                [_firstPaymentDataArr addObject:ratioItem];
            }
        }
    }
    else
    {
        _firstPaymentDataArr = [NSMutableArray arrayWithArray:allRatio];
    }
}

- (void)selectFirstPayment:(NSString *)firstPaymentValue
{
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
    }
    else
    {
        if ([_btnFirstPayment.titleLabel.text isEqualToString:@"100%首付"]) {
            _fenqiNum = 0;
            NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", (int)_allproperty.count - 1]];
            for (UIButton *propertyBtn in propertyBtns) {
                propertyBtn.enabled = YES;
                [self updateButtonState:propertyBtn];
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
    
    _firstPaymentRatio = [[firstPaymentValue stringByReplacingOccurrencesOfString:@"%%" withString:@""] floatValue] / 100;
    
    [self updateOrderMoney];
}

- (void)refreshFirstPaymentRatio:(id)sender
{
    if (_firstPaymentDataArr.count > 0 ) {
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
}

- (void)test:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    MyLog(@"click");
    btn.selected = !btn.selected;
    [self updateButtonState:btn];
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

-(BOOL)isInOwnedSKU:(NSString *)property1 AnotherProperty:(NSString *)property2
{
    BOOL isIn = NO;
    
    NSArray *SKUArr = [_goodsSpec objectForKey:@"price"];
    for (id skuItem in SKUArr) {
        NSString *skuStr = [skuItem objectForKey:@"attr_val_list"];
        
        //TODO 可能有BUG
        NSRange isRange1 = [skuStr rangeOfString:property1 options:NSCaseInsensitiveSearch];
        NSRange isRange2 = [skuStr rangeOfString:property2 options:NSCaseInsensitiveSearch];
        if (isRange1.location != NSNotFound && isRange2.location != NSNotFound) {   //SKU中都包含了这2个属性
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

-(BOOL)isInOwnedSKU:(NSArray *)propertyValues
{
    BOOL isIn = NO;
    
    NSArray *SKUArr = [_goodsSpec objectForKey:@"price"];
    for (id skuItem in SKUArr) {
        NSString *skuStr = [skuItem objectForKey:@"attr_val_list"];
        
        int inCount = 0;
        for (id propertyValue in propertyValues) {
            NSRange isRange = [skuStr rangeOfString:propertyValue options:NSCaseInsensitiveSearch];     //TODO 可能有BUG
            if (isRange.location != NSNotFound) {
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

- (void)findDisableProperty:(UIButton *)selectedBtn
{
    NSString *selectedStr = selectedBtn.titleLabel.text;
    for (int j = 0; j < _allproperty.count - 1; j++) {
        if (j == selectedBtn.tag) {
            continue;
        }
        
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", j]];
        for (UIButton *propetyBtn in propertyBtns) {
            NSArray *propetyArr = @[selectedStr, propetyBtn.titleLabel.text];
            if (![self isInOwnedSKU:propetyArr]) {
                //            if (![self isInOwnedSKU:selectedStr AnotherProperty:propetyBtn.titleLabel.text]) {
                propetyBtn.enabled = NO;
            }
        }
        
    }
}

- (void)findDisablePropertyWithTwoSelectedButtons:(NSArray *)selectedBtns
{
    if (!(selectedBtns.count == 2)) {
        return;
    }
    
    UIButton *selectedBtn1 = selectedBtns[0];
    UIButton *selectedBtn2 = selectedBtns[1];
    NSString *selectedStr1 = selectedBtn1.titleLabel.text;
    NSString *selectedStr2 = selectedBtn2.titleLabel.text;
    for (int j = 0; j < _allproperty.count - 1; j++) {
        if (j == selectedBtn1.tag || j == selectedBtn2.tag) {
            continue;
        }
        
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", j]];
        for (UIButton *propetyBtn in propertyBtns) {
            NSArray *propetyArr = @[selectedStr1, selectedStr2, propetyBtn.titleLabel.text];
            if (![self isInOwnedSKU:propetyArr]) {
                propetyBtn.enabled = NO;
            }
        }
    }
    
    
}

- (void)updateOrderMoney
{
    float firstPaymentMoney = _goodsPrice * _firstPaymentRatio;
    _lblFirstPayment.text = [NSString stringWithFormat:@"¥ %0.2f", firstPaymentMoney];
    
    _needPayMoney = _goodsPrice - firstPaymentMoney;
    float fenqiPrice = _needPayMoney / _fenqiNum;
    if (_fenqiNum == 0) {
        fenqiPrice = 0.0;
    }
    
    self.lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥ %.2f X %d期", fenqiPrice, _fenqiNum];
    
    if ([[AppUtils iosVersion] floatValue] >= 7.0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.lblMonthPayment.text];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:GENERAL_COLOR_RED
                                 range:NSMakeRange(3, [NSString stringWithFormat:@"¥ %.2f", fenqiPrice].length)];
        
        self.lblMonthPayment.attributedText = attributedString;
    }
}

- (void)onPropertyClick:(id)sender
{
    //初始化
    int i = 0;
    for (i = 0; i < _allproperty.count - 1; i++) {
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            propetyBtn.enabled = YES;
        }
    }
    
    NSMutableArray *selectedPropertyBtns = [NSMutableArray array];
    UIButton *btn=(UIButton*)sender;
    
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
    
    //for disable propety
    for (id selectedBtn in selectedPropertyBtns) {
        [self findDisableProperty:selectedBtn];
    }
    
    if (selectedPropertyBtns.count == 2) {
        [self findDisablePropertyWithTwoSelectedButtons:[selectedPropertyBtns copy]];
    }
    
    if (selectedPropertyBtns.count == 3) {
        [self findDisablePropertyWithTwoSelectedButtons:@[selectedPropertyBtns[0], selectedPropertyBtns[1]]];
        [self findDisablePropertyWithTwoSelectedButtons:@[selectedPropertyBtns[0], selectedPropertyBtns[2]]];
        [self findDisablePropertyWithTwoSelectedButtons:@[selectedPropertyBtns[1], selectedPropertyBtns[2]]];
    }
    
    
    self.lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥ %@", @"0"];
    _goodsPrice = 0.0;
    _fenqiNum = 0;
    if (selectedItemCount == _allproperty.count - 1) {
        NSArray *priceArr = [_goodsSpec objectForKey:@"price"];
        for (id priceItem in priceArr) {
            if ([selectedStr isEqualToString:[priceItem objectForKey:@"attr_val_list"]]) {
                self.lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥ %@", [priceItem objectForKey:@"attr_price"]];
                _goodsPrice = [[priceItem objectForKey:@"attr_price"] floatValue];
                _attrValList = [priceItem objectForKey:@"attr_val_list"];
                _goodsID_SKU = [priceItem objectForKey:@"goods_id"];
                break;
            }
        }
        
        NSMutableArray *propertyBtns = [_allproperty objectForKey:[NSString stringWithFormat:@"%d", i]];
        for (UIButton *propetyBtn in propertyBtns) {
            if (propetyBtn.isSelected) {
                _fenqiNum = [propetyBtn.titleLabel.text intValue];
                
                [self updateOrderMoney];
                
                break;
            }
        }
    }
    
}

- (UIButton *)makeAttrButton:(int)j attrItem:(id)attrItem theProperty:(NSMutableArray *)theProperty
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
    
    [self.contentView addSubview:btnColor];
    [theProperty addObject:btnColor];
    
    _theLeft += titleSize.width + 10.0;
    return btnColor;
}

//- (UIButton *)addPropertyButton:(float)theVSpace i:(int)i tag:(id)tag j:(int)j theProperty:(NSMutableArray *)theProperty
//{
//    if (i == 0) {
//        _theLeft = _theLeft + 35;
//    }else if (i%4 == 0) {
//        _theLeft = 11 + 35;
//        _theTop = _theTop + theVSpace;
//    }else{
//        _theLeft = _theLeft + 65;
//    }
//    UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    tagBtn.frame = CGRectMake(_theLeft, _theTop, 58.f, 30.f);
//    [tagBtn setBackgroundImage:[UIImage imageNamed:@"detail_body_button_n"] forState:UIControlStateNormal];
//    [tagBtn setBackgroundImage:[UIImage imageNamed:@"detail_body_button_h"] forState:UIControlStateSelected];
//    [tagBtn setBackgroundImage:[UIImage imageNamed:@"detail_body_button_d"]  forState:UIControlStateDisabled];
//    [tagBtn setTitle:tag forState:UIControlStateNormal];
//    [tagBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
//    //    [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [tagBtn setTitleColor:[UIColor colorWithRed:58.0/255 green:63.0/255 blue:74.0/255 alpha:1.0] forState:UIControlStateNormal];
//    [tagBtn setTitleColor:[UIColor colorWithRed:232.0/255 green:132.0/255 blue:54.0/255 alpha:1.0] forState:UIControlStateSelected];
//    [tagBtn setTitleColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0] forState:UIControlStateDisabled];
//    [tagBtn addTarget:self action:@selector(onPropertyClick:) forControlEvents:UIControlEventTouchUpInside];
//    [tagBtn setTag:j];
//    [self.scrollView addSubview:tagBtn];
//    
//    [theProperty addObject:tagBtn];
//    return tagBtn;
//}

- (void)initGoodsProperty
{
    _theTop = 155.0;
    
    //all SKU String
    _ownedSKUStr = @"";
    NSArray *ownedSKUItems = [_goodsSpec objectForKey:@"price"];
    for (id itemPrice in ownedSKUItems) {
        _ownedSKUStr = [NSString stringWithFormat:@"%@,%@", _ownedSKUStr, [itemPrice objectForKey:@"attr_val_list"]];
    }
    NSArray *firstSKU = [[ownedSKUItems.firstObject objectForKey:@"attr_val_list"] componentsSeparatedByString:@":"];
    
    //各种属性按钮等等
    _allproperty = [NSMutableDictionary dictionary];
    _theTop = _theTop - 20;
    _theLeft = 10;
    
    NSArray *fenqiStrArr = [_goodsSpec objectForKey:@"support_periods"];
    NSMutableArray *fenqiArr = [NSMutableArray array];
    for (id fenqiItem in fenqiStrArr) {
        NSString *fenqiStr = [NSString stringWithFormat:@"%@月", fenqiItem];
        [fenqiArr addObject:fenqiStr];
    }
    NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict3 setValue:@"分期" forKey:@"attr_name"];
    [dict3 setValue:fenqiStrArr forKey:@"attr_value"];
    [dict3 setValue:@"1234" forKey:@"attr_id"];
    
    NSMutableArray *arr = [_goodsSpec objectForKey:@"attributes"];
    int j = 0;
    int k = 0;  //firstSKU's index
    for (id item in arr) {
//        _theTop = _theTop + theVSpace;
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = [NSString stringWithFormat:@"%@:", [item objectForKey:@"attr_name"]];
        [self.contentView addSubview:lblProperty];
        
        NSMutableArray *theProperty = [NSMutableArray array];
        _theLeft = 60.0;
        NSArray *attrValues = [item objectForKey:@"attr_value"];
        int i = 0;
        for (id attrItem in attrValues) {
            NSRange isRange = [_ownedSKUStr rangeOfString:attrItem options:NSCaseInsensitiveSearch];
            if (isRange.location == NSNotFound) {
                continue;
            }
            
            UIButton *btnColor = [self makeAttrButton:j attrItem:attrItem theProperty:theProperty];
            
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
    
    {   //首付
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop + 3, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = @"首付：";
        [self.contentView addSubview:lblProperty];
        
        _btnFirstPayment = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFirstPayment setBackgroundImage:[UIImage imageNamed:@"specifications_body_backgroud_d"] forState:UIControlStateNormal];
        _btnFirstPayment.frame = CGRectMake(60.0, _theTop, 71.0, 31.0);
        _btnFirstPayment.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        [_btnFirstPayment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnFirstPayment setTitle:@"零首付" forState:UIControlStateNormal];
        _btnFirstPayment.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_btnFirstPayment addTarget:self action:@selector(refreshFirstPaymentRatio:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnFirstPayment];
        
        _lblFirstPayment = [[UILabel alloc] initWithFrame:CGRectMake(141.0, _theTop + 3, 100.0, 21.0)];
        _lblFirstPayment.font = GENERAL_FONT13;
        _lblFirstPayment.text = @"¥ 588.80";
        [self.contentView addSubview:_lblFirstPayment];
        
        _theTop += 40.0;
    }
    
    UIButton *defaultFenqiBtn = nil;
    {
        id item = dict3;
        UILabel *lblProperty = [[UILabel alloc] initWithFrame:CGRectMake(10.0, _theTop, 50.0, 21.0)];
        lblProperty.font = GENERAL_FONT13;
        lblProperty.text = [NSString stringWithFormat:@"%@:", [item objectForKey:@"attr_name"]];
        [self.contentView addSubview:lblProperty];
        
        NSMutableArray *theProperty = [NSMutableArray array];
        _theLeft = 60.0;
        NSArray *attrValues = [item objectForKey:@"attr_value"];
        int i = 0;
        for (id attrItem in attrValues) {
            UIButton *btnAttr = [self makeAttrButton:j attrItem:attrItem theProperty:theProperty];
            if (i == attrValues.count - 1) {
                defaultFenqiBtn = btnAttr;
            }
            
            i++;
        }
        
        _theTop += 40.0;
        [_allproperty setObject:theProperty forKey:[NSString stringWithFormat:@"%d", j]];
        j++;
    }
    
    if (defaultFenqiBtn != nil) {
        [self onPropertyClick:defaultFenqiBtn];
    }
    
    
    [self makeFirstPaymentRange];
    if (_firstPaymentDataArr.count > 0) {
        [self selectFirstPayment:[_firstPaymentDataArr objectAtIndex:0]];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _accountInfo = [AppUtils getUserInfo];
    
    UIView *line = [AppUtils makeLine:_viewWidth theTop:64.0];
    [self.view addSubview:line];
    
    self.scrollView.contentSize = CGSizeMake(_viewWidth, 500.0 + 500.0);
    self.scrollView.scrollEnabled = YES;
    
    [self.goodsImg sd_setImageWithURL:[NSURL URLWithString:[self.goodsDetail objectForKey:@"images"][0] ] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
    self.lblGoodsName.text = [self.goodsDetail objectForKey:@"name"];
    self.lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%@", [self.goodsDetail objectForKey:@"price"]];
    
    // Initialize Data
    _firstPaymentDataArr = [NSMutableArray array];
    _firstPaymentRatio = 1.0;

    
    [self getGoodsSpecFromAPI];
}

-(void)setButtonTitle:(NSString *)title button:(UIButton*) button{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [MobClick beginLogPageView:TAG];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [MobClick endLogPageView:TAG];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

- (IBAction)doBuyAction:(id)sender {
    if (_goodsPrice <= 0) {
        [AppUtils showInfo:@"请选择商品"];
        return;
    }
    
    if (_fenqiNum <= 0) {
        [AppUtils showInfo:@"请选择分期数"];
        return;
    }
    
    MyLog(@"%f    %f", _credit,  _needPayMoney);
    if (_credit < _needPayMoney) {
        [AppUtils showInfo:@"信用额度不足"];
        return;
    }
    
    OrderConfirmViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmIdentifier"];
    vc.goodsID = _goodsID_SKU;
    vc.goodsDetail = self.goodsDetail;
    vc.goodsPrice = _goodsPrice;
    vc.firstPaymentRatio = _firstPaymentRatio;
    vc.fenqiNum = _fenqiNum;
    [AppUtils pushPage:self targetVC:vc];
}
@end
