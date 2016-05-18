//
//  GoodsActivitiesViewController.h
//  renrenfenqi
//
//  Created by DY on 15/1/15.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsActivitiesViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *thumbnailUrl;

@end
