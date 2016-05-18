//
//  OrderOKViewController.m
//  renrenfenqi
//
//  Created by coco on 14-11-14.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "OrderOKViewController.h"
#import "MyOrdersViewController.h"
#import "AppUtils.h"
#import "AppDelegate.h"

@interface OrderOKViewController ()

@end

@implementation OrderOKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)doOrderDetail:(id)sender {
    MyOrdersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MyOrdersIdentifier"];
    [AppUtils pushPage:self targetVC:vc];
}

- (IBAction)doGoAction:(id)sender {
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tbc = (UITabBarController*)[app.window rootViewController];
    if(![tbc isKindOfClass: [UITabBarController class]]){
        return;
    }
    [tbc setSelectedIndex:0];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
