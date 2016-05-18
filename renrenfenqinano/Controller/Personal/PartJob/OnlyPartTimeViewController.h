//
//  OnlyPartTimeViewController.h
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, ButtonTag) {
    USER_STATUS_NOT_LOGIN,        // 没有登录
    USER_STATUS_NOT_FINISH_FIRST, // 信息都没完成
    USER_STATUS_NOT_FINISH_SECOND,// 完成第一步
    USER_STATUS_ALL_FINISH,       // 资料都完成
};

@interface OnlyPartTimeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (assign, nonatomic) ButtonTag buttonTag;

@end
