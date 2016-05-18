//
//  StudentAuthViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/17.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "StudentAuthViewController.h"
#import "AppUtils.h"

@interface StudentAuthViewController ()

@end

@implementation StudentAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
