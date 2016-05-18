//
//  WishCommitViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/4.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "WishCommitViewController.h"
#import "MyWishViewController.h"
#import "AppUtils.h"
#import "AppDelegate.h"

@interface WishCommitViewController ()

@end

@implementation WishCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 按钮响应

- (IBAction)myWishBtn:(UIButton *)sender {
    NSLog(@"点击进入我的心愿单");
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        UIViewController *rootViewer = [viewControllers objectAtIndex:0];
                        [viewControllers removeAllObjects];
                        [viewControllers addObject:rootViewer];
                        
                        MyWishViewController *myWishVC = [self.storyboard  instantiateViewControllerWithIdentifier:@"MyWishIdentifier"];
                        myWishVC.hidesBottomBarWhenPushed = YES;
                        [viewControllers addObject:myWishVC];
                        [self.navigationController setViewControllers:viewControllers animated:NO];
                        
                    }
                    completion:NULL];
    
}

- (IBAction)goHomeBtn:(UIButton *)sender {
    NSLog(@"幸哥的接口--点击进入主页");
    [self back:nil];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tbc = (UITabBarController*)[app.window rootViewController];
    if(![tbc isKindOfClass: [UITabBarController class]]){
        return;
    }
    [tbc setSelectedIndex:0];
}

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
