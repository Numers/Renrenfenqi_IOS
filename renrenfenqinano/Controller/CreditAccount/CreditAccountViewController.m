//
//  CreditAccountViewController.m
//  renrenfenqi
//
//  Created by coco on 15-4-28.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "CreditAccountViewController.h"
#import "CurMonthRepaymentViewController.h"
#import "NeedPaymentListViewController.h"
#import "MyBillsAutoRepaymentViewController.h"
#import "OrderFirstPaymentViewController.h"
#import "BillsListViewController.h"
#import "UserLoginViewController.h"
#import "AppUtils.h"
#import "DPMeterView.h"
#import "RFBillHomeManager.h"
@interface CreditAccountViewController ()
{
    NSNumber *m_leftCreditAccount;
    NSNumber *m_allCreditAccount;
    NSString *m_month_need;
    NSString *m_allNeed;
    NSArray *m_firstList;
    
    UIStoryboard *mainStoryBoard;
}
@end

@implementation CreditAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableList.delegate = self;
    self.tableList.dataSource = self;
    self.tableList.tableFooterView = [UIView new];
    self.tableList.backgroundColor = GENERAL_COLOR_GRAY2;
    
    mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBillIndex];
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

-(void)getBillIndex
{
    [[RFBillHomeManager defaultManager] getBillIndexSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        if (dic) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data) {
                m_leftCreditAccount = [data objectForKey:@"credit"];
                m_allCreditAccount = [data objectForKey:@"all"];
                m_month_need = [data objectForKey:@"month_need"];
                m_allNeed = [data objectForKey:@"all_need"];
                m_firstList = [data objectForKey:@"first_list"];
                [self.tableList reloadData];
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger status = [[dic objectForKey:@"status"] integerValue];
        if(status == -1)
        {
            UserLoginViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"UserLoginIdentifier"];
            vc.writeInfoMode = WriteInfoModeOption;
            vc.parentClass = [CreditAccountViewController class];
            [AppUtils pushPageFromBottomToTop:self targetVC:vc];
        }
        [AppUtils showInfo:[dic objectForKey:@"message"]];
        
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showInfo:@"网络连接失败"];
    }];
}
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0 green:68/255.0 blue:75/255.0 alpha:1.0];
    cell.textLabel.font = GENERAL_FONT13;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
//{
//    //    if (sectionIndex == 0)
//    //        return 0;
//    
//    return 44;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        return;
    }
    if (m_firstList) {
        if (m_firstList.count >= indexPath.row) {
            NSDictionary *dic = [m_firstList objectAtIndex:indexPath.row - 1];
            OrderFirstPaymentViewController *orderFirstPaymentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"OrderFirstPaymentIdentifier"];
            [orderFirstPaymentVC setOrderDic:dic];
            [AppUtils pushPage:self targetVC:orderFirstPaymentVC];
        }else{
            if (indexPath.row == m_firstList.count + 1) {
                //本月待还款
                CurMonthRepaymentViewController *curMonthRepayVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CurMonthRepaymentIdentifier"];
                [AppUtils pushPage:self targetVC:curMonthRepayVC];
            }
            
            if(indexPath.row == m_firstList.count + 2)
            {
                //全部待还款
                NeedPaymentListViewController *needPaymentListVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NeedPaymentListIdentifier"];
                [AppUtils pushPage:self targetVC:needPaymentListVC];
            }
            
            if(indexPath.row == m_firstList.count + 4)
            {
                //账单
                BillsListViewController *billListVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BillsListIdentifier"];
                [AppUtils pushPage:self targetVC:billListVC];
            }
            
            if (indexPath.row == m_firstList.count + 5) {
                //设置自动还款
                MyBillsAutoRepaymentViewController *myBillAutoRepaymentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyBillsAutoRepaymentIdentifier"];
                [AppUtils pushPage:self targetVC:myBillAutoRepaymentVC];
            }
        }
    }else{
        if (indexPath.row == 1) {
            //本月待还款
            CurMonthRepaymentViewController *curMonthRepayVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CurMonthRepaymentIdentifier"];
            [AppUtils pushPage:self targetVC:curMonthRepayVC];

        }
        
        if(indexPath.row == 2)
        {
            //全部待还款
            NeedPaymentListViewController *needPaymentListVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NeedPaymentListIdentifier"];
            [AppUtils pushPage:self targetVC:needPaymentListVC];
        }
        
        if(indexPath.row == 4)
        {
            //账单
            BillsListViewController *billListVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"BillsListIdentifier"];
            [AppUtils pushPage:self targetVC:billListVC];
        }
        
        if (indexPath.row == 5) {
            //设置自动还款
            MyBillsAutoRepaymentViewController *myBillAutoRepaymentVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyBillsAutoRepaymentIdentifier"];
            [AppUtils pushPage:self targetVC:myBillAutoRepaymentVC];
        }
    }
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 320;
    } else {
        if (m_firstList) {
            if (indexPath.row == m_firstList.count + 3) {
                return 10;
            }
        }else{
            if (indexPath.row == 3) {
                return 10;
            }
        }
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSInteger rows;
    if (m_firstList) {
        rows = m_firstList.count + 6;
    }else{
        rows = 6;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"personalcenter_body_backgroud_n"]]];
        
        UILabel *leftAccountLabel = (UILabel *)[cell viewWithTag:3];
        [leftAccountLabel setText:[NSString stringWithFormat:@"%.2f",[m_leftCreditAccount floatValue]]];
        UILabel *allAccountLabel = (UILabel *)[cell viewWithTag:4];
        [allAccountLabel setText:[NSString stringWithFormat:@"总金额:%.2f",[m_allCreditAccount floatValue]]];
        
        DPMeterView *limitView = (DPMeterView *)[cell viewWithTag:1];
        CAShapeLayer *circle = [CAShapeLayer layer];
        // Make a circular shape
        MyLog(@"w %0.2f, h %0.2f", limitView.frame.size.width, limitView.frame.size.height);
        UIBezierPath *circularPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 180.0, 180.0) cornerRadius:180.0];
        circle.path = circularPath.CGPath;
        // Configure the apperence of the circle
        //        circle.fillColor = [UIColor lightGrayColor].CGColor;
        circle.strokeColor = [UIColor whiteColor].CGColor;
        circle.lineWidth = 0;
        limitView.layer.mask = circle;
        limitView.trackTintColor = [UIColor clearColor];
        limitView.progressTintColor = [UIColor whiteColor];
        
        [self performSelector:@selector(addUp:) withObject:limitView afterDelay:2.0];
        return cell;
    }
    
    if (m_firstList) {
        if (indexPath.row <= m_firstList.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"creditaccount_body_payment_n.png"]];
            lblTitle.text = @"首付";
            NSDictionary *m = [m_firstList objectAtIndex:indexPath.row - 1];
            [lblMoney setText:[m objectForKey:@"first_price"]];
        }else{
            if (indexPath.row == m_firstList.count + 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
                UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
                
                [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_monthly"]];
                lblTitle.text = @"本月待还款";
                lblMoney.text = m_month_need;
            }
            
            if (indexPath.row == m_firstList.count + 2) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
                UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
                
                [imgTitle setImage:[UIImage imageNamed:@"RFCredit_body_needPayBill"]];
                lblTitle.text = @"全部待还款";
                lblMoney.text = m_allNeed;
            }
            
            if (indexPath.row == m_firstList.count + 3) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
            }
            
            if (indexPath.row == m_firstList.count + 4) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
                UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
                
                [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_bill"]];
                lblTitle.text = @"账单";
                lblMoney.text = @"";

            }
            
            if (indexPath.row == m_firstList.count + 5) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
                
                UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
                UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
                UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
                
                [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_repayment"]];
                lblTitle.text = @"设置自动还款";
                lblMoney.text = @"";
            }
        }
    }else{
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_monthly"]];
            lblTitle.text = @"本月待还款";
            lblMoney.text = m_month_need;
        }
        
        if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCredit_body_needPayBill"]];
            lblTitle.text = @"全部待还款";
            lblMoney.text = m_allNeed;
        }
        
        if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
        }
        
        if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_bill"]];
            lblTitle.text = @"账单";
            lblMoney.text = @"";
            
        }
        
        if (indexPath.row == 5) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_repayment"]];
            lblTitle.text = @"设置自动还款";
            lblMoney.text = @"";
        }
    }
    /*
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
            [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"personalcenter_body_backgroud_n"]]];
            
            UILabel *leftAccountLabel = (UILabel *)[cell viewWithTag:3];
            [leftAccountLabel setText:[NSString stringWithFormat:@"%.2f",[m_leftCreditAccount floatValue]]];
            UILabel *allAccountLabel = (UILabel *)[cell viewWithTag:4];
            [allAccountLabel setText:[NSString stringWithFormat:@"总金额:%.2f",[m_allCreditAccount floatValue]]];
            
            DPMeterView *limitView = (DPMeterView *)[cell viewWithTag:1];
            CAShapeLayer *circle = [CAShapeLayer layer];
            // Make a circular shape
            MyLog(@"w %0.2f, h %0.2f", limitView.frame.size.width, limitView.frame.size.height);
            UIBezierPath *circularPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 180.0, 180.0) cornerRadius:180.0];
            circle.path = circularPath.CGPath;
            // Configure the apperence of the circle
            //        circle.fillColor = [UIColor lightGrayColor].CGColor;
            circle.strokeColor = [UIColor whiteColor].CGColor;
            circle.lineWidth = 0;
            limitView.layer.mask = circle;
            limitView.trackTintColor = [UIColor clearColor];
            limitView.progressTintColor = [UIColor whiteColor];
            
            [self performSelector:@selector(addUp:) withObject:limitView afterDelay:2.0];
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"creditaccount_body_payment_n.png"]];
            lblTitle.text = @"首付";
            NSMutableString *firstAccount = [NSMutableString string];
            if (m_firstList) {
                for (NSDictionary *m in m_firstList) {
                    if ([m isEqual:[m_firstList lastObject]]) {
                        [firstAccount appendFormat:@"%@",[m objectForKey:@"first_price"]];
                    }else{
                        [firstAccount appendFormat:@"%@,",[m objectForKey:@"first_price"]];
                    }
                }
                
            }
            lblMoney.text = firstAccount;
        }
            break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_monthly"]];
            lblTitle.text = @"本月待还款";
            lblMoney.text = m_month_need;
        }
            break;
        case 3:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"creditaccount_body_payment_n.png"]];
            lblTitle.text = @"全部待还款";
            lblMoney.text = m_allNeed;
        }
            break;
        case 4:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorIdentifier" forIndexPath:indexPath];
        }
            break;
        case 5:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_bill"]];
            lblTitle.text = @"账单";
            lblMoney.text = @"";

        }
            break;
        case 6:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
            
            UIImageView *imgTitle = (UIImageView *)[cell viewWithTag:1];
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
            UILabel *lblMoney = (UILabel *)[cell viewWithTag:3];
            
            [imgTitle setImage:[UIImage imageNamed:@"RFCreditAccount_body_repayment"]];
            lblTitle.text = @"设置自动还款";
            lblMoney.text = @"";
        }
            break;
            
        default:
            break;
    }*/
    
    return cell;
}

- (void)addUp : (DPMeterView *)limitView {
    float progress = [m_leftCreditAccount floatValue] / [m_allCreditAccount floatValue];
    [limitView add:progress animated:YES];
}

@end