//
//  MyBillsBankSelectViewController.m
//  renrenfenqi
//
//  Created by coco on 14-12-4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "MyBillsBankSelectViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

#define NOSELECTED @"-1"

@interface MyBillsBankSelectViewController ()
{
    NSMutableArray *_banks;

    float _viewWidth;
    float _viewHeight;
}

@end

@implementation MyBillsBankSelectViewController

- (void)getBanksFromAPI
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    //TODO red_list need to modify
    NSDictionary *parameters = nil;
    NSString *theURL = [NSString stringWithFormat:@"%@%@", SECURE_BASE, GET_WITHHOLDING_BANKS];
    [manager GET:theURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        MyLog(operation.responseString);
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            _banks = [jsonData objectForKey:@"data"];
            [self.tableBanks reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [AppUtils showInfo:@"提交失败，请稍后再试！"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _viewWidth = self.view.bounds.size.width;
    _viewHeight = self.view.bounds.size.height;
    
    _tableBanks.dataSource = self;
    _tableBanks.delegate = self;
    
    _banks = [NSMutableArray array];
    
    [self getBanksFromAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.delegate = nil;
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
    
    self.selectedBank = _banks[indexPath.row];
    
    [self.tableBanks reloadData];
    
    [self back];
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
    return _banks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    NSDictionary *theBank = _banks[indexPath.row];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 150.0, 21.0)];
    lblTitle.font = GENERAL_FONT13;
    lblTitle.text = [theBank objectForKey:@"name"];
    
    UIImageView *imgSelect = [[UIImageView alloc] initWithFrame:CGRectMake(_viewWidth - 30.0 - 15.0, 8.0, 30.0, 30.0)];
    
    if ([[theBank objectForKey:@"key"] isEqualToString:[self.selectedBank objectForKey:@"key"]]) {
        [imgSelect setImage:[UIImage imageNamed:@"chooseabank_body_choose_h"]];
    }
    else
    {
        [imgSelect setImage:[UIImage imageNamed:@"chooseabank_body_choose_n"]];
    }
    
    [cell addSubview:lblTitle];
    [cell addSubview:imgSelect];
    
    return cell;
}


- (void)back {
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.navigationController popViewControllerAnimated:NO];
                        
                        if(_delegate && [_delegate respondsToSelector:@selector(MyBillsBankSelectVCDidDismisWithData:)])
                        {
                            [_delegate MyBillsBankSelectVCDidDismisWithData:self.selectedBank];
                        }
                    }
                    completion:NULL];
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
    [self back];
}
@end
