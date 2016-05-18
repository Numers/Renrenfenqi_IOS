//
//  AppDelegate.h
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTKKeyValueStore.h"
#import "WXApi.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *secondStoryBord;
@property (strong, nonatomic) YTKKeyValueStore *store;
@property (copy, nonatomic) NSString *registerID;

-(void)checkJobApply;
@end

