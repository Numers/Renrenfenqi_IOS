//
//  Util.h
//  HousingFund
//
//  Created by ShaCai Tech on 14-6-16.
//  Copyright (c) 2014年 dgm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GFPlaceholderView.h"
#import "URLManager.h"

typedef NS_ENUM(NSUInteger, WriteInfoMode) {
    WriteInfoModeNone,
    WriteInfoModeOption,
    WriteInfoModeMust,
};

#define PERPAGESIZE @"15"
#define CATEGORY_ALL_ID @"-1"
#define MENU_HOME_TAG @"0"
#define MENU_HELP_TAG @"1"
#define PHONE400 @"400-780-0087"
#define GENERAL_FONT12 [UIFont fontWithName:@"HelveticaNeue" size:12]
#define GENERAL_FONT13 [UIFont fontWithName:@"HelveticaNeue" size:13]
#define GENERAL_FONT14 [UIFont fontWithName:@"HelveticaNeue" size:14]
#define GENERAL_FONT15 [UIFont fontWithName:@"HelveticaNeue" size:15]
#define GENERAL_FONT18 [UIFont fontWithName:@"HelveticaNeue" size:18]
#define GENERAL_FONT20 [UIFont fontWithName:@"HelveticaNeue" size:20]
#define GENERAL_COLOR_RED [UIColor colorWithRed:244/255.0 green:78/255.0 blue:78/255.0 alpha:1.0]
#define GENERAL_COLOR_RED2 [UIColor colorWithRed:255/255.0 green:123/255.0 blue:124/255.0 alpha:1.0]
#define GENERAL_COLOR_GRAY [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0]
#define GENERAL_COLOR_GRAY2 [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]
#define GENERAL_COLOR_GRAY3 [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]

#define USER_GUIDE_COLOR1 [UIColor colorWithRed:1.0 green:0.98 blue:0.67 alpha:1.0]
#define USER_GUIDE_COLOR2 [UIColor colorWithRed:0.71 green:0.99 blue:0.77 alpha:1.0]
#define USER_GUIDE_COLOR3 [UIColor colorWithRed:0.88 green:0.78 blue:0.99 alpha:1.0]
#define USER_GUIDE_COLOR4 [UIColor colorWithRed:0.99 green:0.67 blue:0.67 alpha:1.0]



#define API_MAP_GEOCODER @"http://apis.map.qq.com/ws/geocoder/v1/"
#define QQMAP_KEY @"FIZBZ-DK5AV-3OXP7-UZ22T-J57BK-QKBFU"
#define UMENG_KEY @"5459bc14fd98c5ff93002fbb"

//#define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_ 1


#define UMENG_TEST_KEY @"53d09d5656240be587091099"
// 微信平台ID
#define WeChatID @"wx11df78a299fd8119"
#define WeChatSecret @"9d2991e4adc78ab71ca537161b3fce09"

#define ISDEVELOPERTEST NO  //developer test switch
//#define ISTEST 1 //test switch 0:production 1:test

//#if ISTEST
////test
//#define API_BASE @"http://test.api.renrenfenqi.com/"
//#define SECURE_BASE @"http://test.secure.renrenfenqi.com/"
//#define IMAGE_BASE @"http://test.image.renrenfenqi.com/"
//#define JOB_BASE @"http://test.job.renrenfenqi.com/"
//#define API_INT @"http://test.int.renrenfenqi.com/"
//#define API_BASE @"http://stage.api.renrenfenqi.com/"
//#define SECURE_BASE @"http://stage.secure.renrenfenqi.com/"
//#define IMAGE_BASE @"http://stage.image.renrenfenqi.com/"
//#define JOB_BASE @"http://stage.job.renrenfenqi.com/"
//#define API_INT @"http://stage.int.renrenfenqi.com/"
////#define API_BASE @"http://host-secure.renrenfenqi.com/api/"
////#define SECURE_BASE @"http://host-secure.renrenfenqi.com/"
////#define IMAGE_BASE @"http://host-image.renrenfenqi.com/"
//#else
////production
//#define API_BASE @"http://api.renrenfenqi.com/"
//#define SECURE_BASE @"https://secure.renrenfenqi.com/"
//#define IMAGE_BASE @"http://img.renrenfenqi.com/"
//#define JOB_BASE @"http://job.renrenfenqi.com/"
//#define API_INT @"http://int.renrenfenqi.com/"
//#endif

//API version
#define API_INT_VERSION @"v1"

#ifdef DEBUG
#define MyLog(...) NSLog(__VA_ARGS__)
#else
#define MyLog(...)
#endif

/**
    接口，宏
 */
//#define ORDER_LIST @"mobile/student/xyts_lists"
#define ORDER_DETAIL @"mobile/student/get_kfmessage"
#define SUBMIT_PREPARE_GOODS @"mobile/student/stock"
#define SUBMIT_CANCEL_ORDER @"mobile/student/destroy"
#define SUBMIT_GIVE_GOODS @"mobile/student/sign"
#define SCHOOLS_BY_CITY @"mobile/student/getSchools"
#define PAYMENT_METHODS @"pay/PayMode/list"
#define UPLOAD_STUDENT_IMAGE @"mobile/student/up_image"
#define SUBMIT_DEVICETOKEN @"phone/get_app"
#define SUBMIT_STUDENT_INFO @"mobile/student"
#define GET_STUDENT_INFO @"mobile/student/get_xytsmessage"
#define GET_STUDENT_INFO_PAYMENT @"pay/PayMode/student"
//#define USER_REG @"auth/user/reg"
//#define USER_CAPTCHA_REG @"auth/user/captchaToReg"
#define USER_CAPTCHA_RESET @"auth/user/captchaToReset"
#define USER_LOGOUT @"auth/user/logout"
//#define USER_RESETPASSWORD @"auth/user/resetPassword"

/**
    接口，版本2
 */
//interface v2
#define USER_KEY @"8JZtPjD9rQxlEPSkUK"
#define HOME_IF2 @"interface/v2/goods/ios"
//#define HOME_IF @"interface/v2.2/goods/ios"
#define HOME_IF @"interface/v3.0/goods/index/ios"
#define TOPIC_LIST @"interface/v2.2/goods/story/ios"
#define HOME_CATEGORIES @"interface/v2.2/goods/appcat/ios"
#define CATEGORY_LIST @"interface/v2/goods/list/{cname}/ios"
#define BRAND_LIST @"interface/v2.2/goods/brand/{brandid}/ios"
#define GOODS_DETAIL @"interface/v2/goods/detail/{goodsid}/ios"
#define USER_LOGIN @"interface/user/login/ios"
#define USER_CAPTCHA_REG @"interface/user/regCode/ios"
#define USER_CAPTCHA_VERIFY @"interface/user/codeVerify/ios"
#define USER_REG @"interface/user/reg/ios"
#define USER_CAPTCHA_FORGET @"interface/user/forgetCode/ios"
#define USER_RESETPASSWORD @"interface/user/forget/ios"
#define GOODS_SPEC @"interface/v2/goods/specCredit/{goodsid}/ios"
#define SHOPPING_RED_COUNT @"red_packet/red_count"
#define USER_ADDRESS @"address"
#define SUBMIT_ORDER @"front/order/ios"
#define BILLS_LIST @"pay/PersonalBills/ios"
#define BILLS_ALIPAY @"pay/pay/PersonalAlipay/paybusno/ios"
#define ALIPAY_NOTIFY @"pay/pay/PersonalAlipayWire/notify/ios"
#define ALIPAY_FIRSTPAYMENT_NOTIFY @"pay/pay/alipayWireless/notify/ios"
#define JOBPAY_PAYINFO @"pay/pay/JobPay/paybusno/ios"
#define ALIPAY_JOYPAY_NOTIFY @"pay/pay/JobAlipayWire/notify/ios"
#define GET_WITHHOLDING_BANKS @"pay/PayMode/withholding/bank"
#define SUBMIT_WITHHOLDING_SETTING @"pay/payway/contract/ios"
#define ORDER_LIST @"pay/CreditAccount/order/list/ios"
#define SEARCH @"interface/v2/goods/search/ios"
#define SEARCH_HOT_GOODS @"interface/v2/goods/search/hot/ios"
#define RATELIST @"interface/v2/goods/appraise/{goodsid}/ios"
//#define GET_ADDRESS @"mobile/student/getProvinces"
//#define GET_SCHOOLS @"mobile/student/getSchools"
#define ADD_ADDRESS @"front/address/ios"
#define GET_ADDRESS ADD_ADDRESS
#define GOODS_RATE @"interface/v2/goods/appraise/{goodsid}/ios"
#define GET_GOODS_RATE @"interface/v2/goods/appraiseOne/{goodsid}/ios"
#define ORDER_TRACK @"order_info/order_track"
#define GET_WITHHOLDINGINFO @"pay/payway/withholdingInfo/ios"
//#define GOODS_DETAIL_SPEC_NOLOGIN  @"interface/v2.2/goods/explicit/{goodsid}/ios"
//#define GOODS_DETAIL_SPEC_LOGIN @"interface/v2.2/goods/specCredit/{goodsid}/ios"
#define GOODS_DETAIL_SPEC_NOLOGIN  @"interface/v2.3/goods/explicit/{goodsid}/ios"
#define GOODS_DETAIL_SPEC_LOGIN @"interface/v2.3/goods/explicitCredit/{goodsid}/ios"
#define HTML5_NEWVERSION @"interface/file/getnew/ios"

#define GET_AREA @"front/area"
#define GET_SCHOOLS @"front/school"

//配置存储
#define CFG_TABLE          @"cfg_table"   // config
#define HTML5_ZIP_VERSION  @"h5_zip_ver"  // HTML5下载包版本


#define STR_LOGIN_TIMEOUT @"登录过期，需要重新登录"

//获取区域或学校标记
#define TYPE_AREA 1
#define TYPE_SCHOOL 2

// 认证关闭开启接口
#define APP_AUTH @"interface/v2/auth"

// 消息通知key
#define GET_SCHOLL_LIST           @"get_school_list"      // 用于监听去获取学校
#define LOCTION_KEY               @"loltion_key"          // 所属地
#define UPDATE_PERSONNAL_INFO     @"update_personal_info" // 刷新个人信息
#define UPDATE_AUTH_INFO          @"update_auth_info"     // 刷新认证信息：学生认证，地址完善
#define UPDATE_ONLY_PARTTIME_DATA @"update_only_parttime_data"
#define UPDATE_JOB_DETAIL         @"update_job_detail"

// web访问网址
#define URL_ABOUT        @"http://m.renrenfenqi.com/spage/about.html"         //关于我们
#define URL_HELP         @"http://m.renrenfenqi.com/spage/help.html"          //使用帮助
#define URL_RED_USE_ROLE @"http://m.renrenfenqi.com/spage/red-packet.html"    //红包规则
#define URL_LOGIN_UP     @"http://m.renrenfenqi.com/spage/agreement.html"     //注册协议
#define URL_LINKAGE      @"http://m.renrenfenqi.com/spage/agreement-1.html"   //联动协议
#define URL_PARTIME_JOB  @"http://m.renrenfenqi.com/spage/job-agreement.html" //兼职协议

// 本地数据存储
#define USER_TABLE          @"user_table"   // 用户信息存储表
#define USER_ID             @"uid"          // 用户ID
#define USER_TOKEN          @"token"        // 用户token
#define USER_NICKNAME       @"nikename"     // 用户昵称
#define USER_HEAD_PIC       @"avatar"       // 头像图片地址
#define USER_CREDIT_ALL     @"credit_all"   // 用户的信用额度上限
#define USER_CITY           @"userCity"     // 当前城市
#define USER_AREA           @"userArea"     // 当前区域

// 个人中心相关接口
#define RED_PACKET_DETAIL    @"red_packet"                  // 获取红包列表
#define USE_RED_PACKET       @"red_packet/useing"           // 使用红包
#define MY_POINTS            @"intergral"                   // 获取我的积分
#define ADD_MY_POINTS        @"intergral/add/"              // 增加积分
#define POINTS_DRAW_RED      @"intergral/draw_redp"         // 积分抽取红包
#define USER_SIGN_IN         @"intergral/sign_in"           // 用户签到
#define STUDENT_AUTH         @"mobile/student/stu_auth"     // post:提交数据 get:获取数据
#define UPLOAD_STUDENT_PIC   @"mobile/student/stu_image"    // 学生上传认证照片
#define GET_PROVINECES       @"mobile/student/getProvinces" // 获取省市区接口
#define GET_SCHOOL_LIST      @"mobile/student/getSchools"   // 获取学校
#define CHANGE_PASSWORD      @"interface/user/modify/ios"   // 修改密码
#define USER_LOG_OUT         @"interface/user/logout/ios"   // 注销账号
#define MODIFY_NICKNAME      @"interface/v2/info/name/ios"  // 修改昵称
#define MODIFY_HEADPIC       @"interface/v2/info/avatar/ios"// 修改头像图片
#define GET_USER_INFO        @"interface/v2/info/ios"       // 获取个人信息
#define GET_BILL_AND_CON     @"pay/PersonalBills/billAndCon/ios"   // 获取是否代扣+当前账单
#define USE_CON_RED_USE      @"pay/PersonalPay/contractRedUse/ios" // 代扣红包使用
#define USER_CREDIT_INFO     @"pay/payway/credit/ios"              // 获取用户的信用额度
#define GET_USER_CENTER_INFO @"user"                               // 获取积分红包消费额度
// 心愿单
#define GET_WISH_LIST      @"wish/wish_lists"  // 获取热门心愿单
#define GET_MY_WISH_LIST   @"wish/my_wish"     // 获取我的心愿单
#define COMMIT_MY_WISH     @"wish"             // 提交心愿单
#define COMMIT_WISH_PRAISE @"wish/laud"        // 提交热门心愿单点赞
// 兼职接口
#define GET_JOBS_LIST         @"job/v1/ios"               // 获取兼职信息列表
#define HOT_CITY_LIST         @"job/v1/city/ios"          // 获取兼职的热门城市
#define MY_JOBS_LIST          @"job/v1/getapply/ios"      // 我的兼职
#define POST_JOB_INFO         @"job/v1/post_job_info/ios" // 上传完善个人资料
#define GET_JOBS_TYPE         @"job/v1/position/ios"      // 获取总的兼职岗位类型
#define POST_JOBS_INFO_INTENT @"job/v1/post_job_info_intent/ios"// 上传兼职时间和岗位意向
#define GET_JOBDETAIL         @"job/v1/show/ios"
#define GET_MYJOB_SETTING     @"job/v1/getinfo/ios"
#define APPLY_JOB             @"job/v1/apply/ios"
#define GET_CITY_ID           @"job/v1/region/ios"        // 获取城市ID 是否支持业务
#define GET_JOBS_DATA         @"job/v2/ios"               // 获取兼职列表
#define GET_JOB_DETAIL        @"job/v2/show/ios"          // 兼职详情
#define GET_PARTTIME_GOODS    @"job/v2/position/ios"      // 兼职购物的商品
#define GET_PARTTIME_JOBS     @"job/v2/positionList/ios"  // 兼职购的商品对应的工种
#define GET_PARTTIME_DAY      @"job/v2/day/ios"           // 兼职购物的时间
#define GET_PARTTIME_INFO     @"job/v2/getinfo/ios"       // 获取兼职基本和意向2份资料信息
// 活动图文接口
#define GET_ACTIVITY_INFO    @"activity/activity_main" // 获取图文主题的赞次数和评论数量
#define POST_ADD_PRAISECOUNT @"activity/laud"          // 申请点赞
#define GET_COMMENTS_DATA    @"activity/appraise"      // 获取评论列表
#define ADD_COMMENT          @"activity/appraise_add"  // 增加评论

#define URLKEY_IOS      @"9e304d4e8df1b74cfa009913198428ab"// html判断访问客户端类型
#define SHARE_URL_KEY   @"855a3b1b5f04a16bb093201a1e8c4910"// 分享用到的url
#define URL_PROTOCOL    @"renrenfenqi://"                  // html交互协议


#define NOTIFY_REPAYMENT_OK @"RepaymentOK"
#define NOTIFY_ALIPAY_CALLBACK @"AlipayCallBack"
#define NOTIFY_JOBSETTING_OK @"JobSettingOK"

#define PAYMENT_WAY_WITHHOLD @"银行代扣"
#define PAYMENT_WAY_ALIPAY @"支付宝"

#define NOTIFY_REMOTE @"RemoteNotification"

#define UNSELECTED -1

#define PROVINCESTEP 0
#define CITYSTEP 1
#define DISTRICTSTEP 2

//支付宝相关
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088511976480245"
//收款支付宝账号
#define SellerID  @"renrenkeji@renrenfenqi.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @"q3g7khdi2qhjbvh5czpysmxtrbs2gtpl"

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBANYYLBNvvbYJxaCYpWouH0Wo8E4qlJs6jxpb5MYDLcO6RjZ3WNm5LVrM+7166P7PgMvR/EQB193aRt5BnjrOELMmSyyg/WmBqx2sbMbYWNYgIkjr7nHOJANGCPVaSwJmMK5heohD66j1sMcIC4ewQk6SlpK01FNVpZmzoTf5dpObAgMBAAECgYBfSdjsObK1P/ou9WHCNY8DoSJ7l+YWhOTGdZoIK8gFsnWnrkzkcs/l9xAgkID9UHvhu69M0YkznAAo0gnL4IV7dkVidp/pUaL3mFmAAzT9i1o76G+GGrRrh+S9uu79DbtcAAG7eH+dO8A7ib0XM13maImfWSSYj9M0DsYN2mrzcQJBAPkmEeuae/mF/QMCTxFFzkIHb/swe4r8TjySCUZZmTc8rlpuxKhPjIoBZ32phRbNnNcWwKHgD7YSnKfUsWcOLzMCQQDb+1SvhT6GV+Wy6UIIhS3m1KI0YxYBNE7eH8RDFXAyv+xNu9d1SEfjHFtERWiEJ49i6N3oIChgqG4qdDzqdqn5AkAtoo99vBohJi2ls3KQE10oMvyL4eF/H5+k8IrKW/b4ayD0Z32V5pwzWvZ9yeMaviaQLxaxj7zQ+K/A/fBQlASJAkAOFZVid4F9UHtgbRbRPNWnhc2s1Ps/sH2sMxR5xxGb7jXO9EvjMnGH1PTy9g6vB2lix84NYqGzLpV/GlocGOThAkAwbQ9RHvXvqbRl7crPv6qqWlAV9uJ5XERjmz8rYY9hLgyWqHbpxBeZu1VkQaUIDVKTNLmxUt6CXp/6JvP84AYa"


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

// iPhone 5 support
#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:(Byte)r/255.0 green:(Byte)g/255.0 blue:(Byte)b/255.0 alpha:a]

// 判断当前设备系统版本
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
//设备屏幕大小
#define _MainScreenFrame   [[UIScreen mainScreen] bounds]
//设备屏幕宽
#define _MainScreen_Width  _MainScreenFrame.size.width
//设备屏幕宽
#define _MainScreen_Height  _MainScreenFrame.size.height

@interface AppUtils : NSObject


+ (NSString*) machineName;
+ (NSString*) iosVersion;
+ (NSString*) appVersion;
+ (NSString*) appBuild;
+ (NSString*) channel;

+ (NSString*) mainUDID;

+ (NSString *)trimWhite:(NSString *)str;

+ (BOOL)isMobileNumber:(NSString *)mobileNumString;
+ (BOOL)isIDCardNumber:(NSString *)value;
+ (BOOL)isEmailValid:(NSString *)email;
+ (BOOL)isNullStr:(NSString *)str;
+ (NSString *)readAPIField:(NSDictionary *)dict key:(NSString *)theKey;
+ (NSString *)makeSignStr:(NSMutableDictionary *)parameters;
+ (NSString *)makeMoneyString:(NSString*)money;
+ (BOOL)isLogined:(NSString *)uid;
+ (void)pushPage:(UIViewController *)startVC targetVC:(UIViewController *)vc;
+ (void)popToPage:(UIViewController *)startVC targetVC:(UIViewController *)vc;
+ (void)goBack:(UIViewController *)myVC;
+ (void)pushPageFromBottomToTop:(UIViewController *)startVC targetVC:(UIViewController *)vc;
+ (void)goBackFromTopToBottom:(UIViewController *)myVC;
+ (NSDictionary *)getUserInfo;
+ (UIView *)makeLine:(float)theWidth theTop:(float)theTop;
+ (void)makeBorder:(UIView *)view;

+ (void)showInfo:(NSString*)str;
+ (void)showSuccess:(NSString*)str;
+ (void)showError:(NSString*)str;

+ (int)getToInt:(NSString*)strtemp; // 字符串转字符的长度

+ (void)showLoadIng:(NSString *)text;    // 数据请求中 菊花显示
+ (void)hideLoadIng;
+ (void)showLoadIng;
+ (void)showLoadSuceess:(NSString *)text;// 加载成功处理
+ (void)showLoadInfo:(NSString *)text;   // 弹窗信息提示

+ (UIViewController*) topMostController;

+ (BOOL)judgeStrIsEmpty:(NSString *)str;
+ (NSString *)filterNull:(NSString *)str;

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)messag; // UIAlertView窗口

+(NSString *)md5:(NSString *)str;
@end
