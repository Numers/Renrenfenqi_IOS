//
//  CommonWebViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *commonWebView;

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *titleString;

@end
