//
//  SchoolListViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/1.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "SchoolListViewController.h"
#import "AppUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"

@interface SchoolListViewController ()

@end

static NSString *cellIdentifiler = @"Cell";

@implementation SchoolListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shoolTableView.delegate = self;
    self.shoolTableView.dataSource = self;
    
    [self.shoolTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.shoolTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.shoolTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.shoolTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.shoolTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.schoolArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    
    if (self.schoolArr.count <= indexPath.row) {
        return cell;
    }
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:10];
    if (nil == contentLabel) {
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.frame.size.width - 30, 44)];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.font = GENERAL_FONT13;
        contentLabel.textColor = UIColorFromRGB(0x000000);;
        contentLabel.numberOfLines = 1;
        contentLabel.tag = 10;
        [cell addSubview:contentLabel];
    }
    
    contentLabel.text = [self.schoolArr[indexPath.row] objectForKey:@"school_name"];
    
    return cell;
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.schoolArr.count <= indexPath.row) {
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(selectSchool:)]) {
        [self.delegate selectSchool:[self.schoolArr objectAtIndex:indexPath.row]];
    }
    
    [self back:nil];
}

#pragma mark 按钮响应
- (IBAction)back:(UIButton *)sender {
    [AppUtils goBack:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
