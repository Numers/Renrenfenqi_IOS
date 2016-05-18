//
//  AppUtils.m
//  HousingFund
//
//  Created by ShaCai Tech on 14-6-16.
//  Copyright (c) 2014年 dgm. All rights reserved.
//

#import "AppUtils.h"
#import <sys/utsname.h>
#import "NSString+MD5.h"
#import "TWMessageBarManager.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UserLoginViewController.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>

#define MBTAG  1001

@implementation AppUtils

/*
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod5,1"   on iPod Touch Fifth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPad3,2":  on iPad 3(GSM+CDMA)
 @"iPad3,3":  on iPad 3(GSM)
 @"iPad3,4":  on iPad 4(WiFi)
 @"iPad3,5":  on iPad 4(GSM)
 @"iPad3,6":  on iPad 4(GSM+CDMA)
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5
 @"iPad3,4"   on 4th Generation iPad
 @"iPad2,5"   on iPad Mini
 @"iPhone5,1" on iPhone 5(GSM)
 @"iPhone5,2" on iPhone 5(GSM+CDMA)
 @"iPhone5,3  on iPhone 5c(GSM)
 @"iPhone5,4" on iPhone 5c(GSM+CDMA)
 @"iPhone6,1" on iPhone 5s(GSM)
 @"iPhone6,2" on iPhone 5s(GSM+CDMA)
 */


+ (NSString*) machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *result = [NSString stringWithCString:systemInfo.machine
                                          encoding:NSUTF8StringEncoding];
    return result;
}


+ (NSString*) iosVersion {
    
    return [NSString stringWithFormat:@"%.2f", [[[UIDevice currentDevice] systemVersion] floatValue]];
}

+ (NSString*) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString*) appBuild {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*) channel {
    return @"official";
}



+ (NSString*) mainUDID {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6) {
        return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] md5_16];
    }
    else {
        return [[self getMacAddress] md5_16];
    }
}

+ (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    return nil;
}

+ (BOOL)isMobileNumber:(NSString *)mobileNumString
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
//    NSString *MOBILEString = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString *MOBILEString = @"^1([3-9][0-9])\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    
    NSString *CMString = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    
    NSString * CUString = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    
    NSString * CTString = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    
    // NSString * PHSString = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILEString];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CMString];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CUString];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CTString];
    
    if (([regextestmobile evaluateWithObject:mobileNumString] == YES)
        || ([regextestcm evaluateWithObject:mobileNumString] == YES)
        || ([regextestct evaluateWithObject:mobileNumString] == YES)
        || ([regextestcu evaluateWithObject:mobileNumString] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
    身份证验证
 */
+ (BOOL)isIDCardNumber:(NSString *)value {
    //检查 去掉两端的空格
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //检查长度
    int length = 0;
    if (!value) {
        return NO;
    }else {
        length = value.length;
        
        if (length != 15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11", @"12", @"13", @"14", @"15", @"21", @"22", @"23", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"41", @"42", @"43", @"44", @"45", @"46", @"50", @"51", @"52", @"53", @"54", @"61", @"62", @"63", @"64", @"65", @"71", @"81", @"82", @"91"];
    
    //检查省份代码
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year = 0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year % 4 ==0 || (year % 100 ==0 && year % 4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];// 测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];// 测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch > 0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year % 4 ==0 || (year % 100 ==0 && year % 4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];// 测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];// 测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch > 0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S % 11;
                NSString *M = @"F";
                NSString *JYM = @"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)]; // 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}

+ (BOOL)isEmailValid:(NSString *)email
{
    if (email == (id)[NSNull null] || email.length == 0) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return ([emailTest evaluateWithObject:email] == YES);
    
    
}

+ (BOOL)isNullStr:(NSString *)str
{
    if (str == (id)[NSNull null] || str.length == 0) {
        return YES;
    }
    
    return NO;
}

/**
    读取来自接口的数据
 */
+ (NSString *)readAPIField:(NSDictionary *)dict key:(NSString *)theKey
{
    return [self isNullStr:[dict objectForKey:theKey]]? @"":[dict objectForKey:theKey];
}

/**
    接口使用的签名验证
 */
+ (NSString *)makeSignStr:(NSMutableDictionary *)parameters
{
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *urlStr = @"";
    BOOL isFirst = YES;
    for (NSString *key in sortedKeys) {
        if (isFirst) {
            urlStr = [NSString stringWithFormat:@"%@=%@",key, parameters[key]];
            isFirst = NO;
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"%@&%@=%@", urlStr, key, parameters[key]];
        }
        
    }
    
    NSString *signStr = [[NSString stringWithFormat:@"%@%@", urlStr, USER_KEY] md5_16];
    return signStr;
}


+ (NSString *)trimWhite:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)makeMoneyString:(NSString*)money
{
    return [NSString stringWithFormat:@"¥%@", money];
}

+ (NSDictionary *)getUserInfo
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *uid = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    if ([self isNullStr:uid]) {
        uid = @"-1";
        token = @"";
    }
    
    NSDictionary *userInfo = @{@"info":@{@"uid":uid}, @"token":token};
    
    return userInfo;
}

+ (BOOL)isLogined:(NSString *)uid
{
    if (![self isNullStr:uid]) {
        if ([uid integerValue] > 0) {
            return YES;
        }
    }
    
    return NO;
}

/**
    弹出登录界面使用
 */
+ (void)pushPageFromBottomToTop:(UIViewController *)startVC targetVC:(UserLoginViewController *)vc
{
    vc.hidesBottomBarWhenPushed = YES;
    vc.parentController = startVC;
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:0.5];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromTop];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [startVC.navigationController pushViewController:vc animated:YES];
//    [startVC.navigationController.view.layer addAnimation:animation
//                            forKey:kCATransition];
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:vc];
    [navigationController setNavigationBarHidden:YES];
    
    //now present this navigation controller modally
    [startVC presentViewController:navigationController
                       animated:YES
                     completion:^{
                         
                     }];
}

/**
    登录界面使用
 */
+ (void)goBackFromTopToBottom:(UIViewController *)myVC
{
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:0.5];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromBottom];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [myVC.navigationController popViewControllerAnimated:YES];
//    [myVC.navigationController.view.layer addAnimation:animation
//                                                forKey:kCATransition];
    
    [myVC dismissViewControllerAnimated:YES completion:nil];
    [self hideLoadIng];
//    [self hidePlaceHolder];
}

+ (void)pushPage:(UIViewController *)startVC targetVC:(UIViewController *)vc
{
//    [UIView transitionWithView:startVC.navigationController.view
//                      duration:0.1
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        vc.hidesBottomBarWhenPushed = YES;
//                        [startVC.navigationController pushViewController:vc animated:NO];
//                    }
//                    completion:NULL];
    
    
    vc.hidesBottomBarWhenPushed = YES;
    [startVC.navigationController pushViewController:vc animated:YES];
}

+ (void)popToPage:(UIViewController *)startVC targetVC:(UIViewController *)vc
{
//    [UIView transitionWithView:startVC.navigationController.view
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        [startVC.navigationController popToViewController:vc animated:NO];
//                    }
//                    completion:NULL];
    
    [startVC.navigationController popToViewController:vc animated:YES];
}

+ (void)goBack:(UIViewController *)myVC
{
//    [UIView transitionWithView:myVC.navigationController.view
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        [myVC.navigationController popViewControllerAnimated:NO];
//                    }
//                    completion:NULL];
    [myVC.navigationController popViewControllerAnimated:YES];
    [self hideLoadIng];
//    [self hidePlaceHolder];
    
}

+ (UIView *)makeLine:(float)theWidth theTop:(float)theTop {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, theTop, theWidth, 0.5)];
    line.backgroundColor = GENERAL_COLOR_GRAY3;
    return line;
}

+ (void)makeBorder:(UIView *)view
{
    [view.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [view.layer setBorderWidth:0.5];
}


+(void)showInfo:(NSString*)str
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@""
//                                                   description:str
//                                                          type:TWMessageBarMessageTypeInfo];
    [self showLoadInfo:str];
}

+(void)showSuccess:(NSString*)str
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@""
//                                                   description:str
//                                                          type:TWMessageBarMessageTypeSuccess];
    [self showLoadInfo:str];
}

+ (void)showError:(NSString*)str
{
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@""
//                                                   description:str
//                                                          type:TWMessageBarMessageTypeError];
    [self showLoadInfo:str];
}

+(int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [strtemp dataUsingEncoding:enc];
    
    return (int)data.length;
}

+ (void)popOnePage:(UIViewController *)vc
{
//    [UIView transitionWithView:vc.navigationController.view
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        [vc.navigationController popViewControllerAnimated:NO];
//                    }
//                    completion:NULL];
    
    [vc.navigationController popViewControllerAnimated:YES];
}

+ (void)showLoadIng:(NSString *)text
{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *appRootVC = [self topMostController];
    
    MBProgressHUD *HUD = (MBProgressHUD *)[appRootVC.view viewWithTag:MBTAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:appRootVC.view];
        HUD.tag = MBTAG;
        [appRootVC.view addSubview:HUD];
    }
    
    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = text;
    HUD.labelFont = GENERAL_FONT15;
    [HUD show:YES];
}

+ (void)showLoadIng
{
    [self showLoadIng:@""];
}

+ (void)hideLoadIng
{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *appRootVC = [self topMostController];
    
    MBProgressHUD *HUD = (MBProgressHUD *)[appRootVC.view viewWithTag:MBTAG];
    HUD.removeFromSuperViewOnHide = YES;
    if (HUD != nil) {
        [HUD hide:YES];
    }
}

+ (void)hidePlaceHolder
{
    //    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *appRootVC = [self topMostController];
    
    GFPlaceholderView *placeHolder = (GFPlaceholderView *)[appRootVC.view viewWithTag:1005];
    if (placeHolder) {
        [placeHolder hide];
    }
}

+ (void)showLoadSuceess:(NSString *)text
{
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *appRootVC = [self topMostController];
    MBProgressHUD *HUD = (MBProgressHUD *)[appRootVC.view viewWithTag:MBTAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:appRootVC.view];
        HUD.tag = MBTAG;
        [appRootVC.view addSubview:HUD];
        [HUD show:YES];
    }
    
    HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
    
    if ([self judgeStrIsEmpty:text]) {
        [HUD hide:YES];
    }else{
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];// 美工切哥成功图片
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = text;
        HUD.labelFont = GENERAL_FONT15;
        [HUD hide:YES afterDelay:1];
    }
//    [self showInfo:text];
}

+ (void)showLoadInfo:(NSString *)text{
    
//    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *appRootVC = [self topMostController];
    MBProgressHUD *HUD = (MBProgressHUD *)[appRootVC.view viewWithTag:MBTAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:appRootVC.view];
        HUD.tag = MBTAG;
        [appRootVC.view addSubview:HUD];
        [HUD show:YES];
    }
    
    HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
    
    if ([self judgeStrIsEmpty:text]) {
        //        HUD.animationType = MBProgressHUDAnimationZoom;
        [HUD hide:YES];
    }else{
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = text;
        HUD.labelFont = GENERAL_FONT15;
        [HUD hide:YES afterDelay:1];
    }
}

+ (BOOL)judgeStrIsEmpty:(NSString *)str{
    
    if (str == nil || [str isEqual: @""] ||[str isEqual:[NSNull null]]) {
        return  YES;
    }
    
    return NO;
}

+ (NSString *)filterNull:(NSString *)str{
    
    if (str == nil || [str isEqual:[NSNull null]]) {
        return @"";
    }
    
    return str;
}

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)messag{
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:title
                                                   message:messag
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];
    
}

+ (UIViewController*) topMostController //for login's modal vc
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
