//
//  GoodsDetailsConfigViewController.h
//  renrenfenqi
//
//  Created by coco on 15-1-16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    详情页配置参数或商品详情
 */

@interface GoodsDetailsConfigViewController : UIViewController

- (IBAction)doBackAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) NSString *htmlStr;
@property (assign, nonatomic) BOOL isDetail;

@end
