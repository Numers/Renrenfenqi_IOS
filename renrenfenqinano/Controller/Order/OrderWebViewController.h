//
//  OrderWebViewController.h
//  renrenfenqi
//
//  Created by coco on 15-5-6.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
    HTML5版商品详情页
 */

@interface OrderWebViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSString *goodsID;
@property (strong, nonatomic) NSString *jobType;

@end
