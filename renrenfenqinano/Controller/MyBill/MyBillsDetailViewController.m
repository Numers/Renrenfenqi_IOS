//
//  MyBillsDetailViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsDetailViewController.h"
#import "AppUtils.h"

@interface MyBillsDetailViewController ()
{
    NSMutableArray *_billInfoArr;
    
    float _viewWidth;
    float _viewHeight;
}

@end

@implementation MyBillsDetailViewController

- (void)addBillInfo:(NSString *)theValue theTitle:(NSString *)theTitle {
    NSDictionary *dict = @{@"key":theTitle,
                           @"value":theValue};
    [_billInfoArr addObject:dict];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    UIView *line = [AppUtils makeLine:_viewWidth theTop:63.0];
    [self.view addSubview:line];
    
    self.tableDetail.delegate = self;
    self.tableDetail.dataSource = self;
    
    _billInfoArr = [NSMutableArray array];
    
    if (self.curBillDetail) {
        NSString *theTitle = @"本期应还金额：";
        NSString *theValue = [NSString stringWithFormat:@"¥ %@", [self.curBillDetail objectForKey:@"repayment_money"]];
        [self addBillInfo:theValue theTitle:theTitle];
        
        if (self.lastBillDetail) {
            theTitle = @"上期账单金额：";
            theValue = [NSString stringWithFormat:@"¥ %@", [self.lastBillDetail objectForKey:@"repayment_money"]];
            [self addBillInfo:theValue theTitle:theTitle];
            
            theTitle = @"上期还款金额：";
            if ([[self.lastBillDetail objectForKey:@"discount"] floatValue] > 0) {
                 theValue = [NSString stringWithFormat:@"¥ %0.2f + ¥ %@红包", ([[self.lastBillDetail objectForKey:@"sum_pay_money"] floatValue] - [[self.lastBillDetail objectForKey:@"discount"] floatValue]), [self.lastBillDetail objectForKey:@"discount"]];
            }
            else
            {
                theValue = [NSString stringWithFormat:@"¥ %@", [self.lastBillDetail objectForKey:@"sum_pay_money"]];
            }
            [self addBillInfo:theValue theTitle:theTitle];
            
        }
        else
        {
            theTitle = @"上期账单金额：";
            theValue = @"";
            [self addBillInfo:theValue theTitle:theTitle];
            
            theTitle = @"上期还款金额：";
            theValue = @"";
            [self addBillInfo:theValue theTitle:theTitle];
        }
        
        theTitle = @"本期账单金额：";
        theValue = [NSString stringWithFormat:@"¥ %@", [self.curBillDetail objectForKey:@"cal_repayment_money"]];
        [self addBillInfo:theValue theTitle:theTitle];
        
        theTitle = @"滞纳金：";
        theValue = [NSString stringWithFormat:@"¥ %@", [self.curBillDetail objectForKey:@"late_fee"]];
        [self addBillInfo:theValue theTitle:theTitle];
        
        theTitle = @"最晚还款时间：";
        theValue = [NSString stringWithFormat:@"%@", [self.curBillDetail objectForKey:@"repayment_day"]];
        [self addBillInfo:theValue theTitle:theTitle];
        
        theTitle = @"实际还款时间：";
        theValue = [NSString stringWithFormat:@"%@", [self.curBillDetail objectForKey:@"final_pay_day"]];
        [self addBillInfo:theValue theTitle:theTitle];
        
        theTitle = @"实际还款金额：";
        if ([[self.curBillDetail objectForKey:@"discount"] floatValue] > 0) {
            theValue = [NSString stringWithFormat:@"¥ %0.2f + ¥ %@红包",
                        ([[self.curBillDetail objectForKey:@"sum_pay_money"] floatValue] - [[self.curBillDetail objectForKey:@"discount"] floatValue]), [self.curBillDetail objectForKey:@"discount"]];
        }
        else
        {
            theValue = [NSString stringWithFormat:@"¥ %@", [self.curBillDetail objectForKey:@"sum_pay_money"]];
        }
        [self addBillInfo:theValue theTitle:theTitle];
        
        theTitle = @"状态：";
        theValue = [NSString stringWithFormat:@"%@", [self makeBillStatusStr:[self.curBillDetail objectForKey:@"status"]]];
        [self addBillInfo:theValue theTitle:theTitle];
    }

    
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
    
    NSDictionary *theInfo = [_billInfoArr objectAtIndex:indexPath.row];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 150.0, 21.0)];
    lblTitle.font = GENERAL_FONT13;
    lblTitle.text = [theInfo objectForKey:@"key"];
    
    UILabel *lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(_viewWidth - 15.0 - 130.0, 10.0, 130.0, 21.0)];
    lblTitle2.textAlignment = NSTextAlignmentRight;
    lblTitle2.font = GENERAL_FONT13;
    lblTitle2.text = [theInfo objectForKey:@"value"];
    [cell addSubview:lblTitle];
    [cell addSubview:lblTitle2];
    
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
