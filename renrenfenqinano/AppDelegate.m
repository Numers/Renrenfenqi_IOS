//
//  AppDelegate.m
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "AppDelegate.h"
#import "PersonalCenterViewController.h"
#import "HomeViewController.h"
#import "CreditAccountViewController.h"
#import "AppUtils.h"
#import "MobClick.h"
#import "JCRBlurView.h"
#import "UMFeedback.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AlixPayResult.h"
#import "HomePageViewController.h"
//#import "PartTimeGoodsViewController.h"
#import "RFPartJobViewController.h"
#import "RFPartJobManager.h"
#import "APService.h"
#import "RFGeneralManager.h"

#import "RFLocationHelper.h"
typedef enum{
    PartJob_WorkNotify = 1,
    PartJob_ReportSuccessNotify,
    PartJob_ReportFailedNotify,
    PartJob_PunchNotify,
    PartJob_CommentNotify,
    PartJob_ActivityNotify,
    NormalMessageNotify
}PushCode;
@interface AppDelegate ()
{
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[RFGeneralManager defaultManager] getGlovalVarWithVersion];
    //定位获取城市信息
    [[RFLocationHelper defaultHelper] startLocation];
    //注册推送
    [self pushSettingWithOptions:launchOptions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    // 注册 微信key
    [WXApi registerApp:WeChatID];
    // 定位城市
    [self initLocationDevice];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:251/255.0 green:99/255.0 blue:98/255.0 alpha:1.0]];
    
    if (ISTEST) {
        [MobClick startWithAppkey:UMENG_TEST_KEY reportPolicy:BATCH channelId:@"App Store"]; //for test
    }
    else
    {
        [MobClick startWithAppkey:UMENG_KEY reportPolicy:BATCH channelId:@"App Store"];
        
        [UMFeedback setAppkey:UMENG_KEY];
    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [AppUtils showError:@"网络不给力，请检查下网络!"];
        }
    }];
    
    // 加载第二个故事版
    self.secondStoryBord = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    
    UINavigationController *nc1;
    nc1 = [[UINavigationController alloc] init];
//    HomeViewController *vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"HomeIdentifier"];
    HomePageViewController *vc1 = [storyBoard instantiateViewControllerWithIdentifier:@"HomePageIdentifier"];
    vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"home_tab_home_n"] selectedImage:[UIImage imageNamed:@"home_tab_home_h"]];
    vc1.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -4.0);
    vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(-2.0, 0.0, 2.0, 0.0);
    nc1.viewControllers = [NSArray arrayWithObjects:vc1, nil];
    nc1.navigationBarHidden = YES;
    
    UINavigationController *nc2;
    nc2 = [[UINavigationController alloc] init];
    CreditAccountViewController *vc2 = [storyBoard instantiateViewControllerWithIdentifier:@"CreditAccountIdentifier"];
    vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"账单" image:[UIImage imageNamed:@"home_tab_category_n"] selectedImage:[UIImage imageNamed:@"home_tab_category_h"]];
    vc2.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -4.0);
    vc2.tabBarItem.imageInsets = UIEdgeInsetsMake(-2.0, 0.0, 2.0, 0.0);
    nc2.viewControllers = [NSArray arrayWithObjects:vc2, nil];
    nc2.navigationBarHidden = YES;
    
//    UINavigationController *nc3;
//    nc3 = [[UINavigationController alloc] init];
////    PartTimeGoodsViewController *vc3 = [[PartTimeGoodsViewController alloc] init];
//    RFPartJobViewController *vc3 = [[RFPartJobViewController alloc] init];
//    vc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"兼职购" image:[UIImage imageNamed:@"home_tab_jobs_n"] selectedImage:[UIImage imageNamed:@"home_tab_jobs_h"]];
//    vc3.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -4.0);
//    vc3.tabBarItem.imageInsets = UIEdgeInsetsMake(-2.0, 0.0, 2.0, 0.0);
//    nc3.viewControllers = [NSArray arrayWithObjects:vc3, nil];
//    nc3.navigationBarHidden = YES;
    
    UINavigationController *nc4;
    nc4 = [[UINavigationController alloc] init];
    PersonalCenterViewController *vc4 = [self.secondStoryBord instantiateViewControllerWithIdentifier:@"PersonalCenterIdentifier"];
    vc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"home_tab_mine_n"] selectedImage:[UIImage imageNamed:@"home_tab_mine_h"]];
    vc4.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -4.0);
    vc4.tabBarItem.imageInsets = UIEdgeInsetsMake(-2.0, 0.0, 2.0, 0.0);
    nc4.viewControllers = [NSArray arrayWithObjects:vc4, nil];
    nc4.navigationBarHidden = YES;
    
    tabController.viewControllers = [NSArray arrayWithObjects:nc1, nc2,nc4 ,nil];
    [tabController.tabBar setTintColor:[UIColor redColor]];
    
    [tabController.tabBar setBackgroundColor:[UIColor clearColor]];
    
    self.store = [[YTKKeyValueStore alloc] initDBWithName:@"rrfqdatastore.db"];
    [self.store createTableWithName:USER_TABLE];
    [self.store createTableWithName:CFG_TABLE];
    
    //获取当前兼职工作的审核状态
    [self checkJobApply];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    return YES;
}

-(void)checkJobApply
{
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *keyJobID = [NSString stringWithFormat:@"%@_CurrentApplyJobID",uid];
        NSString *jobId = [[NSUserDefaults standardUserDefaults] objectForKey:keyJobID];
        if (jobId) {
            [[RFPartJobManager defaultManager] searchJobCheckStateWithJobId:jobId WithUid:uid Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *resultDic = (NSDictionary *)responseObject;
                if (resultDic) {
                    NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                    if (dataDic) {
                        NSInteger jobState = [[dataDic objectForKey:@"is_state"] integerValue];
                        if (jobState == 2) {//订单处于审核成功状态，那查看当前用户处于锁定订单的URL,若已锁定走入打卡流程，就不处理，若没有，那么锁定URL进入打卡流程。
                            NSInteger isPunch = [[dataDic objectForKey:@"click"] integerValue];
                            if (isPunch == 0) {
                                NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                NSString *lockURL = [NSString stringWithFormat:@"%@%@/%@?uid=%@&token=%@",BaseJobH5URL,RF_LockPunchURL_API,jobId,uid,[loginInfo objectForKey:@"token"]];
                                [userDefaults setObject:lockURL forKey:key];
                                [userDefaults synchronize];
                            }
                        }
                        
                        if(jobState == 1){//正在申请未审核
                            
                        }
                        
                        if (jobState == 3) {//如果订单处于审核失败或者违约等其他状态，那查看当前用户是否处于锁定URL，若处于锁定，那么解锁
                            NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                            NSString *keyClientId = [NSString stringWithFormat:@"%@_CurrentClientID",uid];
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSString *currentLoadUrl = [userDefaults objectForKey:key];
                            if (currentLoadUrl){
                                [userDefaults removeObjectForKey:key];
                                [userDefaults removeObjectForKey:keyJobID];
                                [userDefaults removeObjectForKey:keyClientId];
                            }
                        }
                    }
                }
            } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }
}

-(void)pushDidLogin:(NSNotification *)notification
{
    [APService setBadge:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    _registerID = [APService registrationID];
    [APService setTags:[NSSet setWithObject:_registerID] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    [[RFGeneralManager defaultManager] sendClientIdSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)tagsAliasCallback:(int)iResCode tags:(NSSet *)tags alias:(NSString *)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

-(void)pushSettingWithOptions:(NSDictionary *)launchOptions
{
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *pushUid = [userInfo objectForKey:@"uid"];
        if (![pushUid isEqualToString:uid]) {
            return;
        }
        NSString *jobId = [userInfo objectForKey:@"job_id"];
        if (jobId) {
            NSInteger code = [[userInfo objectForKey:@"code"] integerValue];
            NSString *lockKey = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
            NSString *lockURL = [[NSUserDefaults standardUserDefaults] objectForKey:lockKey];
            if (lockURL && lockURL.length > 0) {
                return;
            }
            if (code == PartJob_PunchNotify || code == PartJob_ReportSuccessNotify) {
                lockURL = [NSString stringWithFormat:@"%@%@/%@?uid=%@&token=%@",BaseJobH5URL,RF_LockPunchURL_API,jobId,uid,[loginInfo objectForKey:@"token"]];
            }else if (code == PartJob_CommentNotify){
                lockURL = [NSString stringWithFormat:@"%@%@/%@?uid=%@&token=%@",BaseJobH5URL,RF_LockCommentURL_API,jobId,uid,[loginInfo objectForKey:@"token"]];
            }else if (code == PartJob_ReportFailedNotify){
                NSDictionary *loginInfo = [AppUtils getUserInfo];
                NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
                if ([AppUtils isLogined:uid]) {
                    NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                    NSString *keyJobID = [NSString stringWithFormat:@"%@_CurrentApplyJobID",uid];
                    NSString *keyClientId = [NSString stringWithFormat:@"%@_CurrentClientID",uid];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults removeObjectForKey:key];
                    [userDefaults removeObjectForKey:keyClientId];
                    [userDefaults removeObjectForKey:keyJobID];
                }
            }
            
            if (lockURL) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                NSString *keyJobID = [NSString stringWithFormat:@"%@_CurrentApplyJobID",uid];
                [userDefaults setObject:lockURL forKey:key];
                [userDefaults setObject:jobId forKey:keyJobID];
                [userDefaults synchronize];
            }
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    NSDictionary *loginInfo = [AppUtils getUserInfo];
    NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
    if ([AppUtils isLogined:uid]) {
        NSString *pushUid = [userInfo objectForKey:@"uid"];
        if (![pushUid isEqualToString:uid]) {
            return;
        }
        NSString *jobId = [userInfo objectForKey:@"job_id"];
        if (jobId) {
            NSInteger code = [[userInfo objectForKey:@"code"] integerValue];
            NSString *lockKey = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
            NSString *lockURL = [[NSUserDefaults standardUserDefaults] objectForKey:lockKey];
            if (lockURL && lockURL.length > 0) {
                return;
            }
            if (code == PartJob_PunchNotify || code == PartJob_ReportSuccessNotify) {
                lockURL = [NSString stringWithFormat:@"%@%@/%@?uid=%@&token=%@",BaseJobH5URL,RF_LockPunchURL_API,jobId,uid,[loginInfo objectForKey:@"token"]];
            }else if (code == PartJob_CommentNotify){
                lockURL = [NSString stringWithFormat:@"%@%@/%@?uid=%@&token=%@",BaseJobH5URL,RF_LockCommentURL_API,jobId,uid,[loginInfo objectForKey:@"token"]];
            }else if (code == PartJob_ReportFailedNotify){
                NSDictionary *loginInfo = [AppUtils getUserInfo];
                NSString *uid = [[loginInfo objectForKey:@"info"] objectForKey:@"uid"];
                if ([AppUtils isLogined:uid]) {
                    NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                    NSString *keyClientId = [NSString stringWithFormat:@"%@_CurrentClientID",uid];
                    NSString *keyJobID = [NSString stringWithFormat:@"%@_CurrentApplyJobID",uid];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults removeObjectForKey:key];
                    [userDefaults removeObjectForKey:keyClientId];
                    [userDefaults removeObjectForKey:keyJobID];
                }
            }
            
            if (lockURL) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"%@_CurrentLoadURLMark",uid];
                NSString *keyJobID = [NSString stringWithFormat:@"%@_CurrentApplyJobID",uid];
                [userDefaults setObject:lockURL forKey:key];
                [userDefaults setObject:jobId forKey:keyJobID];
                [userDefaults synchronize];
            }
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self checkJobApply];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - add URL回调播放界面
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    if([[url absoluteString] hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    if([[url absoluteString] hasPrefix:@"wx"])
    {
        return [WXApi handleOpenURL:url delegate:self];
    }else {
        AlixPayResult* result = [self handleOpenURL:url];
        
        if (result)
        {
            NSDictionary *theResult = @{@"resultStatus":[NSString stringWithFormat:@"%d", result.statusCode]};
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFY_ALIPAY_CALLBACK
             object:theResult];
        }
        else
        {
            //失败
            [AppUtils showInfo:@"交易失败"];
        }

    }
    
    return YES;
}

#pragma mark - Alipay
//支付宝客户端回调函数

- (AlixPayResult *)resultFromURL:(NSURL *)url {
    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
    return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
    AlixPayResult * result = nil;
    
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        result = [self resultFromURL:url];
    }
    
    return result;
}

#pragma mark 定位处理
// 初始化定位设备
- (void)initLocationDevice{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 100.0f;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 判断手机定位功能是否开启
    [self openLocationPos];
}
-(void)openLocationPos {
    if(IOS8_OR_LATER){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if(self) {
        if ([CLLocationManager locationServicesEnabled]) {
            [_locationManager startUpdatingLocation];
        }
        else{
            [AppUtils showAlertViewWithTitle:@"提示" message:@"请在设置->隐私->位置中允许仁仁分期APP开启定位"];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorLocationUnknown) {
        [AppUtils showAlertViewWithTitle:@"提示" message:@"请在设置->隐私->位置中允许仁仁分期APP开启定位"];
    }else if(error.code == kCLErrorNetwork) {
        [AppUtils showAlertViewWithTitle:@"提示" message:@"请在设置->隐私->位置中允许仁仁分期APP开启定位"];
    }
    else if(error.code == kCLErrorDenied) {
        [AppUtils showAlertViewWithTitle:@"提示" message:@"请在设置->隐私->位置中允许仁仁分期APP开启定位"];
    }
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *loc in locations) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *place in placemarks){
                //                NSString* addressInfo = [NSString stringWithFormat:@"%@%@%@",place.administrativeArea, place.locality, place.subLocality];      // 省市区
                //                NSLog(@"%@", addressInfo);
                
                [manager stopUpdatingLocation];
                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [app.store putString:place.locality withId:USER_CITY intoTable:USER_TABLE];
                [app.store putString:place.subLocality withId:USER_AREA intoTable:USER_TABLE];
            }
        }];
        break;
    }
}

@end
