//
//  CommonWebViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "CommonWebViewController.h"
#import "AppUtils.h"

@interface CommonWebViewController ()

@end

@implementation CommonWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleString;
    self.commonWebView.delegate = self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.url]]];
    [self.commonWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [AppUtils showLoadIng];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [AppUtils showLoadSuceess:@"加载成功"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [AppUtils showLoadInfo:@"网络异常，请求超时"];
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
