//
//  OrderConfirmViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderConfirmViewController.h"
#import "AppUtils.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "OrderAddressViewController.h"

@interface OrderConfirmViewController ()
{
    NSDictionary *_accountInfo;
    NSMutableArray *_curRedPackets;
    int _curRedPacketsMoney;
    
    float _viewWidth;
    float _viewHeight;

    float _cellHeightArr[6];
    NSArray *_cellIDArr;
    
    BOOL _nodata;
    int RPNum;      //number of Red Packet
    
    NSMutableDictionary *_modelDict;
}

@end

@implementation OrderConfirmViewController

- (void)getRedPacketCountFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":[[_accountInfo objectForKey:@"info"] objectForKey:@"uid"]};
    NSString *theURL = [[NSString stringWithFormat:@"%@%@", API_BASE, SHOPPING_RED_COUNT] stringByReplacingOccurrencesOfString:@"{goodsid}" withString:self.goodsID];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
//        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            RPNum = [[jsonData objectForKey:@"count"] intValue];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            [self.tableOrder reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
        
    }];
}

- (BOOL)havePartTimeJob {
    return [[self.orderParams2 valueForKey:@"is_job"] intValue] == 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    persistentDefaults = [NSUserDefaults standardUserDefaults];
    
    _accountInfo = [AppUtils getUserInfo];
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    self.tableOrder.delegate = self;
    self.tableOrder.dataSource = self;
    if ([self.tableOrder respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableOrder setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableOrder respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableOrder setLayoutMargins:UIEdgeInsetsZero];
    }
    
    RPNum = 0;
    
    _cellHeightArr[0] = 65.0;
    _cellHeightArr[1] = 10.0;
    _cellHeightArr[2] = 130.0;
    _cellHeightArr[3] = 10.0;
    _cellHeightArr[4] = 44.0;
    _cellHeightArr[5] = 550.0;
    _cellIDArr = @[@"goodsIdentifier", @"separatorIdentifier", @"orderIdentifier", @"separatorIdentifier", @"shoppingRPIdentifier", @"nextStepIdentifier"];
    
    UIView *lineView = [AppUtils makeLine:_viewWidth theTop:64.0];
    [self.view addSubview:lineView];
    
    _curRedPackets = [NSMutableArray array];
    _curRedPacketsMoney = 0;
    
    _modelDict = [NSMutableDictionary dictionary];
    [_modelDict setValue:[self.orderParams2 valueForKey:@"goods_img"] forKey:@"goods_img_url"];
    [_modelDict setValue:[self.orderParams2 valueForKey:@"goods_name"] forKey:@"goods_name"];
    [_modelDict setValue:[self.orderParams2 valueForKey:@"goods_price"] forKey:@"goods_price"];
    [_modelDict setValue:[self.orderParams2 objectForKey:@"first_pay"] forKey:@"firstPayment"];
    [_modelDict setValue:[self.orderParams1 valueForKey:@"periods"] forKey:@"periods"];
    [_modelDict setValue:[self.orderParams2 valueForKey:@"month_pay"] forKey:@"month_payment_normal"];
    if ([self havePartTimeJob]) {
        [_modelDict setValue:[NSString stringWithFormat:@"%0.2f", [[self.orderParams2 valueForKey:@"job_price"] floatValue] / [[self.orderParams2 objectForKey:@"period"] intValue] ]
                      forKey:@"month_payment_job"];
    } else {
        [_modelDict setValue:@"0" forKey:@"month_payment_job"];
    }
    [_modelDict setValue:@"0" forKey:@"redpacket_money"];
    
    
    [self getRedPacketCountFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.backgroundColor = [UIColor clearColor];
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
    //    NSDictionary *theOrder = [self.orders objectAtIndex:indexPath.row];
    
    if(indexPath.row == 4)
    {
        [self doGetRedPacket:nil];
    }
}



#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeightArr[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (BOOL)haveRedPacket
{
    return _curRedPacketsMoney > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyLog(@"indexpath.row------- = %ld", indexPath.row);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[_cellIDArr objectAtIndex:indexPath.row] forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            UIImageView *imgGoods = (UIImageView *)[cell viewWithTag:1];
            NSArray *theImages = [self.goodsDetail objectForKey:@"images"];
            if (theImages && theImages.count > 0) {
                [imgGoods sd_setImageWithURL:[NSURL URLWithString:[self.goodsDetail objectForKey:@"images"][0] ] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
            }
            
            UILabel *lblGoodsName = (UILabel *)[cell viewWithTag:2];
            lblGoodsName.text = self.goodsName;
        }
            break;
        case 2:
        {
            UILabel *lblGoodsPrice = (UILabel *)[cell viewWithTag:1];
            UILabel *lblFirstPayment = (UILabel *)[cell viewWithTag:2];
            UILabel *lblFenqi = (UILabel *)[cell viewWithTag:3];
            UILabel *lblMonthPayment = (UILabel *)[cell viewWithTag:4];
            
            float thePayMoney = 0.0;
            if ([self haveRedPacket]) {
                lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.2f - ¥%d", [[_modelDict valueForKey:@"goods_price"] floatValue], _curRedPacketsMoney];
                thePayMoney = [[_modelDict valueForKey:@"goods_price"] floatValue] - _curRedPacketsMoney;
                float theFirstPayment =  thePayMoney * self.firstPaymentRatio;
                lblFirstPayment.text = [NSString stringWithFormat:@"首付：¥%.2f(%.0f%%)", theFirstPayment, self.firstPaymentRatio * 100];
                lblFenqi.text = [NSString stringWithFormat:@"分期：%@期", [_modelDict valueForKey:@"periods"]];
                if ([self havePartTimeJob]) {
                    float theMonthPayment = (thePayMoney * (1 - self.firstPaymentRatio) - [[self.orderParams2 valueForKey:@"job_price"] floatValue] ) / [[_modelDict valueForKey:@"periods"] intValue];
                    lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%0.2f + ¥%@兼职", theMonthPayment, [_modelDict valueForKey:@"month_payment_job"]];
                } else {
                    float theMonthPayment = thePayMoney * (1 - self.firstPaymentRatio) / [[_modelDict valueForKey:@"periods"] intValue];
                    lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%0.2f", theMonthPayment];
                }
            }
            else
            {
                lblGoodsPrice.text = [NSString stringWithFormat:@"售价：¥%0.2f", [[_modelDict valueForKey:@"goods_price"] floatValue]];
                lblFirstPayment.text = [NSString stringWithFormat:@"首付：¥%@(%.0f%%)", [_modelDict valueForKey:@"firstPayment"], self.firstPaymentRatio * 100];
                lblFenqi.text = [NSString stringWithFormat:@"分期：%@期", [_modelDict valueForKey:@"periods"]];
                if ([self havePartTimeJob]) {
                    lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%@ + ¥%@兼职", [_modelDict valueForKey:@"month_payment_normal"], [_modelDict valueForKey:@"month_payment_job"]];
                } else {
                    lblMonthPayment.text = [NSString stringWithFormat:@"月供：¥%@", [_modelDict valueForKey:@"month_payment_normal"] ];
                }
            }
            
        }
            break;
        case 4:
        {
            UILabel *lblRPTip = (UILabel *)[cell viewWithTag:1];
            
            if (_curRedPacketsMoney > 0) {
                lblRPTip.text = [NSString stringWithFormat:@"已抵扣¥%d", _curRedPacketsMoney];
            }
            else
            {
                if (RPNum == 0) {
                    lblRPTip.text = @"";
                }
                else
                {
                    lblRPTip.text = [NSString stringWithFormat:@"%d张可用", RPNum];
                }
            }

        }
            break;
            
        default:
            break;
    }
//    NSDictionary *theCategory = [_categoryArr objectAtIndex:indexPath.row];
//    
//    UIImageView *imgCategory = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 50.0, 50.0)];
//    [imgCategory sd_setImageWithURL:[NSURL URLWithString:[theCategory objectForKey:@"banner_path"]] placeholderImage:[UIImage imageNamed:@"list_body_nopic_n"]];
//    //    [imgCategory setImage:[UIImage imageNamed:@"home_body_intelligentwear_n"]];
//    [cell addSubview:imgCategory];
//    
//    UILabel *lblCategoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 10.0, 180.0, 20.0)];
//    lblCategoryTitle.font = GENERAL_FONT12;
//    lblCategoryTitle.text = [NSString stringWithFormat:@"%@  %@", [theCategory objectForKey:@"cat_name"], [theCategory objectForKey:@"english"]];
//    [cell addSubview:lblCategoryTitle];
//    
//    if ([[AppUtils iosVersion] floatValue] >= 7.0) {
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lblCategoryTitle.text];
//        [attributedString addAttribute:NSFontAttributeName
//                                 value:[UIFont fontWithName:@"HelveticaNeue" size:10]
//                                 range:NSMakeRange(lblCategoryTitle.text.length - ((NSString *)[theCategory objectForKey:@"english"]).length, ((NSString *)[theCategory objectForKey:@"english"]).length)];
//        [attributedString addAttribute:NSForegroundColorAttributeName
//                                 value:[UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0]
//                                 range:NSMakeRange(lblCategoryTitle.text.length - ((NSString *)[theCategory objectForKey:@"english"]).length, ((NSString *)[theCategory objectForKey:@"english"]).length)];
//        lblCategoryTitle.attributedText = attributedString;
//    }
//    
//    UILabel *lblCategoryDesc = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 35.0, 180.0, 20.0)];
//    lblCategoryDesc.font = GENERAL_FONT12;
//    lblCategoryDesc.textColor = [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1.0];
//    lblCategoryDesc.text = [theCategory objectForKey:@"cat_desc"];
//    [cell addSubview:lblCategoryDesc];
//    
//    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 15.0 - 16.0, 23.0, 8.0, 12.5)];
//    [imgArrow setImage:[UIImage imageNamed:@"home_body_next_n"]];
//    [cell addSubview:imgArrow];
    
    return cell;
}

#pragma redpacket
- (void)shoppingDeduction:(NSMutableArray*)redPakets totalValue:(int)money
{
    _curRedPackets = redPakets;
    _curRedPacketsMoney = money;
    
    [self.tableOrder reloadData];
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

- (IBAction)doNextAction:(id)sender {
    NSString *redPacketStr = @"";
    for (int i = 0; i < _curRedPackets.count; i++) {
        if (i == 0) {
            redPacketStr = _curRedPackets[i];
        }
        else
        {
            redPacketStr = [NSString stringWithFormat:@"%@|%@", redPacketStr, _curRedPackets[i]];
        }
    }
    
    
    OrderAddressViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderAddressIdentifier"];
    vc.goodsID = self.goodsID;
    vc.firstPaymentRatio = self.firstPaymentRatio;
    vc.periods = self.fenqiNum;
    vc.jobDays = self.jobPrice;
    vc.jobType = self.jobType;
    vc.orderParams = self.orderParams1;
    vc.redPacketID = redPacketStr;
    
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doGetRedPacket:(id)sender {
    //TODO
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ShoppingRedPaketViewController *vc = [app.secondStoryBord instantiateViewControllerWithIdentifier:@"ShoppingRedPaketIdentifier"];
    vc.delegate = self;
    vc.selectedRedPacketArr = _curRedPackets;
    [AppUtils pushPage:self targetVC:vc];
}
@end
