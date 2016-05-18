//
//  MyBillsViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsViewController.h"
#import "HMSegmentedControl.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "MyBillsMoreViewController.h"
#import "MyBillsPaymentViewController.h"
#import "MyBillsAutoRepaymentViewController.h"
#import "MyBillsOrderDetailViewController.h"
#import "MyBillsDetailViewController.h"

@interface MyBillsViewController ()
{
    HMSegmentedControl *_segmentedControl;
    NSDictionary *_accountInfo;
    
    NSMutableDictionary *_bills;
    NSMutableArray *_showBillsArr;
    
    NSMutableArray *_billInfoArr;
    
    NSDictionary *_billNow;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation MyBillsViewController

- (void)doMore
{
    MyBillsMoreViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsMoreIdentifier"];
    vc.bills = _bills;
    [AppUtils pushPage:self targetVC:vc];
}

- (void)initUI
{
    self.lblDebt.text = [NSString stringWithFormat:@"¥%.2f", [[_bills objectForKey:@"not_pay"] floatValue]];
    self.lblRepayment.text = [NSString stringWithFormat:@"总计已还款：¥%.2f", [[_bills objectForKey:@"pay"] floatValue]];
    
    _billNow = [_bills objectForKey:@"now"];
    NSArray *billsArr = [_bills objectForKey:@"list"];
    [_showBillsArr removeAllObjects];
    int billShowCount = 0;
    for (id billItem in billsArr) {
        if ([[billItem objectForKey:@"year_month"] isEqualToString:[_billNow objectForKey:@"year_month"]]) {
            billShowCount++;
            [_showBillsArr addObject:billItem];
        }
        else
        {
            if (billShowCount > 0) {
                billShowCount++;
                [_showBillsArr addObject:billItem];
            }
        }
        
        if (billShowCount >= 4) {
            break;
        }
    }
    
    NSMutableArray *monthArr = [NSMutableArray array];
    for (id billItem in _showBillsArr) {
        NSRange monthRange;
        monthRange.location = 5;
        monthRange.length = 2;
        NSString *monthStr = [NSString stringWithFormat:@"%d月", [[[billItem objectForKey:@"year_month"] substringWithRange:monthRange] intValue]];
        [monthArr addObject:monthStr];
    }
    
    
    if (_showBillsArr.count == 0) {
        [AppUtils showInfo:@"没有要还款的账单"];
//        [self doBackAction:nil];
        self.btnRepay.hidden = YES;
        self.btnMoreMonth.hidden = YES;
        self.tableBill.hidden = YES;
        self.btnAutoRepayment.hidden = YES;
        self.blankView.hidden = NO;
    }else if (_showBillsArr.count > 0) {
        self.blankView.hidden = YES;
        
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:monthArr];
        _segmentedControl.frame = CGRectMake(0.0, 0.0, _viewWidth - 65, 43);
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _segmentedControl.textColor = [UIColor grayColor];
        _segmentedControl.selectedTextColor = [UIColor colorWithRed:231/255.0 green:88/255.0 blue:69/255.0 alpha:1.0];
        _segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:231/255.0 green:88/255.0 blue:69/255.0 alpha:1.0];
        _segmentedControl.selectionIndicatorHeight = 2.0f;
        _segmentedControl.scrollEnabled = YES;
        [self.viewSegment addSubview:_segmentedControl];
        
        
        [self segmentedControlChangedValue:_segmentedControl];
    }
}

- (void)getBillsFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"],
                                 @"token":[_accountInfo objectForKey:@"token"]};
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, BILLS_LIST];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            _bills = [jsonData objectForKey:@"data"];
            
            [self initUI];
        }
        else
        {
            [AppUtils showInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (NSString *)makeBillStatusStr:(NSString*)statusValue
{
    NSString *statusStr = @"";
    switch ([statusValue intValue]) {
        case 0:
            statusStr = @"未还款";
            break;
        case 1:
            statusStr = @"延期还款";
            break;
        case 3:
            statusStr = @"已经还款";
            break;
            
        default:
            break;
    }
    
    return statusStr;
}

- (void)segmentedControlChangedValue:(id)sender
{
    HMSegmentedControl *theSegmentControl = (HMSegmentedControl*)sender;
    
    NSMutableDictionary *theBill = [NSMutableDictionary dictionary];
    switch (theSegmentControl.selectedSegmentIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            theBill = [_showBillsArr objectAtIndex:theSegmentControl.selectedSegmentIndex];
            [_billInfoArr removeAllObjects];
            [_billInfoArr addObject:[theBill objectForKey:@"repayment_day"]];
            [_billInfoArr addObject:[AppUtils makeMoneyString:[theBill objectForKey:@"repayment_money"]]];
            [_billInfoArr addObject:[AppUtils makeMoneyString:[theBill objectForKey:@"late_fee"]]];
            NSString *theRepaymentMoney = [NSString stringWithFormat:@"%0.2f", [[theBill objectForKey:@"cal_repayment_money"] floatValue] - [[theBill objectForKey:@"sum_pay_money"] floatValue]];
            [_billInfoArr addObject:[AppUtils makeMoneyString:theRepaymentMoney]];
            [_billInfoArr addObject:[self makeBillStatusStr:[theBill objectForKey:@"status"]]];
            [_billInfoArr addObject:@"账单明细"];
            [_billInfoArr addObject:@"订单明细"];
            
            [self.tableBill reloadData];
            
            if ([[_billNow objectForKey:@"year_month"] isEqualToString:[theBill objectForKey:@"year_month"]]) {
                self.btnRepay.enabled = YES;
            }
            else
            {
                self.btnRepay.enabled = NO;
            }
        }
            break;
        case 4:
        {
        }
            break;
            
        default:
            break;
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _accountInfo = [AppUtils getUserInfo];
    if (![AppUtils isLogined:[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]]) {
        [self doBackAction:nil];
        [AppUtils showInfo:@"请先登录帐号"];
        return;
    }
    
    _bills = [NSMutableDictionary dictionary];
    _showBillsArr = [NSMutableArray array];
    _billInfoArr = [NSMutableArray array];
    
    self.tableBill.dataSource = self;
    self.tableBill.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getBillsFromAPI)
                                                 name:NOTIFY_REPAYMENT_OK
                                               object:nil];
    
    UIView *theLine = [AppUtils makeLine:_viewWidth theTop:63.0];
    [self.view addSubview:theLine];
    
    [self getBillsFromAPI];
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
    NSDictionary *theBill = [_showBillsArr objectAtIndex:_segmentedControl.selectedSegmentIndex];
    
    if (indexPath.row == 5) {
        NSMutableDictionary *theLastBillDetail = nil;
        if (theBill) {
            NSArray *billsArr = [_bills objectForKey:@"list"];
            int i = 0;
            for (id billItem in billsArr) {
                if ([[billItem objectForKey:@"year_month"] isEqualToString:[theBill objectForKey:@"year_month"]]) {
                    if (i == 0) {
                        theLastBillDetail = nil;
                        break;
                    }
                    else if (i > 0)
                    {
                        theLastBillDetail = billsArr[i - 1];
                    }
                }
                
                i++;
            }
        }
        
        MyBillsDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsDetailIdentifier"];
        vc.lastBillDetail = theLastBillDetail;
        vc.curBillDetail = theBill;
        [AppUtils pushPage:self targetVC:vc];
    }
    else if(indexPath.row == 6)
    {
        //TODO 订单明细
        MyBillsOrderDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsOrderDetailIdentifier"];
        vc.orderArr = [theBill objectForKey:@"data"];
        [AppUtils pushPage:self targetVC:vc];
    }
    
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
    return _billInfoArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 150.0, 21.0)];
    lblTitle.font = GENERAL_FONT13;
    UILabel *lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 15.0 - 100.0, 10.0, 100.0, 21.0)];
    lblTitle2.textAlignment = NSTextAlignmentRight;
    lblTitle2.font = GENERAL_FONT13;
    [cell addSubview:lblTitle];
    [cell addSubview:lblTitle2];
    switch (indexPath.row) {
        case 0:
        {
            lblTitle.text = @"到期还款日：";
            lblTitle2.text = [_billInfoArr objectAtIndex:indexPath.row];
        }
            break;
        case 1:
        {
            lblTitle.text = @"账单金额：";
            lblTitle2.text = [_billInfoArr objectAtIndex:indexPath.row];
        }
            break;
        case 2:
        {
            lblTitle.text = @"滞纳金：";
            lblTitle2.text = [_billInfoArr objectAtIndex:indexPath.row];
        }
            break;
        case 3:
        {
            lblTitle.text = @"应还金额：";
            lblTitle2.text = [_billInfoArr objectAtIndex:indexPath.row];
            lblTitle2.textColor = GENERAL_COLOR_RED;
        }
            break;
        case 4:
        {
            lblTitle.text = @"还款状态：";
            lblTitle2.text = [_billInfoArr objectAtIndex:indexPath.row];
        }
            break;
        case 5:
        {
            lblTitle.text = @"账单明细：";
            
            UIImageView *imgRight = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 15.0 - 10.0, 15.0, 8.0, 13.0)];
            [imgRight setImage:[UIImage imageNamed:@"home_body_next_n"]];
            [cell addSubview:imgRight];
        }
            break;
        case 6:
        {
            lblTitle.text = @"订单明细：";
            MyLog(@"SUCKS");
            
            UIImageView *imgRight = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 15.0 - 10.0, 15.0, 8.0, 13.0)];
            [imgRight setImage:[UIImage imageNamed:@"home_body_next_n"]];
            [cell addSubview:imgRight];
        }
            break;
            
        default:
            break;
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

- (IBAction)doRepaymentAction:(id)sender {
    MyBillsPaymentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsPaymentIdentifier"];
    vc.bill = _billNow;
    [AppUtils pushPage:self targetVC:vc];

}

- (IBAction)doAutoRepaymentAction:(id)sender {
    
    MyBillsAutoRepaymentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyBillsAutoRepaymentIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}

- (IBAction)doMoreBillsAction:(id)sender {
    [self doMore];
}
@end
