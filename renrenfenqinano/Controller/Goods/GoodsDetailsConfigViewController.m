//
//  GoodsDetailsConfigViewController.m
//  renrenfenqi
//
//  Created by coco on 15-1-16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "GoodsDetailsConfigViewController.h"
#import "AppUtils.h"

@interface GoodsDetailsConfigViewController ()

@end

@implementation GoodsDetailsConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *line = [AppUtils makeLine:self.view.bounds.size.width theTop:64.0];
    [self.view addSubview:line];
    
    if (!self.isDetail) {
        self.lblTitle.text = @"配置参数";
    }
    
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    [self.webView loadHTMLString:[self preHandleHtml:self.htmlStr] baseURL:nil];
}

- (NSString *)preHandleHtml:(NSString *)htmlStr
{
    //    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"style=\"\"" withString:@"style=\"width:100%;\""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p><br/></p>" withString:@""];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"style=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"width=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"height=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:&error];
    htmlStr = [regex stringByReplacingMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length]) withTemplate:@""];
    
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<img " withString:@"<img style=\"width:100%;\""];
    
    return htmlStr;
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

- (IBAction)doBackAction:(id)sender {
    [AppUtils goBack:self];
}
@end
