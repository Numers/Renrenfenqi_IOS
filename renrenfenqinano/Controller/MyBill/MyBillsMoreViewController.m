//
//  BillMoreViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsMoreViewController.h"
#import "AppUtils.h"
#import "MyBillsDetailViewController.h"

#define TAG_CELL_MONTH 1
#define TAG_CELL_STATUS 2

@interface MyBillsMoreViewController ()
{
    NSMutableArray *_yearArr;
    NSMutableArray *_billArrByYear;
}

@end

@implementation MyBillsMoreViewController

- (void)makeBillsDivide {
    NSMutableArray *tempArr = [NSMutableArray array];
    NSString *curYear = @"";
    if (_bills) {
        NSArray *billArr = [_bills objectForKey:@"list"];
        for (id billItem in billArr) {
            NSRange range;
            range.location = 0;
            range.length = 4;
            NSString *yearStr = [[billItem objectForKey:@"year_month"] substringWithRange:range];
            if (![curYear isEqualToString:yearStr]) {
                if (![AppUtils isNullStr:curYear]) {
                    [_billArrByYear addObject:[tempArr copy]];
                    [tempArr removeAllObjects];
                }
                curYear = yearStr;
                [_yearArr addObject:curYear];
            }
            
            if ([curYear isEqualToString:yearStr]) {
                [tempArr addObject:billItem];
            }
        }
        
        if (tempArr.count > 0) {
            [_billArrByYear addObject:[tempArr copy]];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    for (id billItem in self.bills) {
////        <#statements#>
//    }
    
    self.tableMore.dataSource = self;
    self.tableMore.delegate = self;
    self.tableMore.tableFooterView = [UIView new];
    
    _yearArr = [NSMutableArray array];
    _billArrByYear = [NSMutableArray array];
    
    [self makeBillsDivide];
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    
    if (sectionIndex != 0) {
        UIView *line1 = [AppUtils makeLine:self.view.frame.size.width theTop:0.0];
        [view addSubview:line1];
    }
//    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 0, 0)];
    label.text = [_yearArr objectAtIndex:sectionIndex];
    label.font = GENERAL_FONT15;
    [label sizeToFit];
    [view addSubview:label];
    
    UIView *line2 = [AppUtils makeLine:self.view.frame.size.width theTop:43.0];
    [view addSubview:line2];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
//    if (sectionIndex == 0)
//        return 0;
    
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *theBill = [[_billArrByYear objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _yearArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[_billArrByYear objectAtIndex:sectionIndex] count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *theBill = [[_billArrByYear objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSRange range;
    range.location = 5;
    range.length = 2;
    
    UILabel *cellMonthName = (UILabel *)[cell viewWithTag:TAG_CELL_MONTH];
    UILabel *cellStatus = (UILabel *)[cell viewWithTag:TAG_CELL_STATUS];
    cellMonthName.text = [NSString stringWithFormat:@"%@月", [[theBill objectForKey:@"year_month"] substringWithRange:range]];
    cellStatus.text = [self makeBillStatusStr:[theBill objectForKey:@"status"]];
    
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}
@end
