//
//  GlobalVar.h
//  renrenfenqi
//
//  Created by baolicheng on 15/6/29.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#ifndef renrenfenqi_GlobalVar_h
#define renrenfenqi_GlobalVar_h
#define TimeOut 10.0f
//#define isTest 1
//#if isTest
////#define BaseURL @"http://test.secure.renrenfenqi.com/pay"
////#define BaseAuditURL @"http://test.audit.renrenfenqi.com"
////#define BaseJobURL @"http://test.job.renrenfenqi.com"
////#define BaseJobH5URL @"http://test.h5.renrenfenqi.com"
//#define BaseURL @"http://stage.secure.renrenfenqi.com/pay"
//#define BaseAuditURL @"http://stage.audit.renrenfenqi.com"
//#define BaseJobURL @"http://stage.job.renrenfenqi.com"
//#define BaseJobH5URL @"http://stage.h5.renrenfenqi.com"
////#define BaseJobH5URL @"http://192.168.2.108/renrenfenqi_job_h5/www"
//#else
//#define BaseURL @"https://secure.renrenfenqi.com/pay"
//#define BaseAuditURL @"http://audit.renrenfenqi.com"
//#define BaseJobURL @"http://job.renrenfenqi.com"
//#define BaseJobH5URL @"http://h5.renrenfenqi.com"
//#endif
//信用账单接口
#define RF_OrderList_API @"/CreditAccount/order/list/ios" //订单列表
#define RF_BillIndex_API @"/CreditAccount/ios" //信用账单首页
#define RF_OrderFirstPrice_API @"/CreditAccount/order/first/ios" //用户需要支付首付的订单接口
#define RF_AlipayWireless_API @"/pay/alipayWireless/notify/ios" //支付宝无线支付异步回调接口
#define RF_MonthBill_API @"/CreditAccount/order/month/ios" //每月还款
#define RF_OrderDetail_API @"/CreditAccount/order/detail/ios" //用户订单详情
#define RF_OrderLateFee_API @"/CreditAccount/order/late/ios" //当月还款滞纳金
#define RF_AlipayRepayment_API @"/pay/PersonalAlipay/paybusno/ios" //支付宝无线还款
#define RF_PersonalAlipayWire_API @"/pay/PersonalAlipayWire/notify/ios" //支付宝无线回调地址
#define RF_RepaymentBill_API @"/CreditAccount/bill/repaymentBill/ios" //已还账单列表
#define RF_PendingBill_API @"/CreditAccount/bill/pendingBill/ios" //未还账单列表
#define RF_BillDetails_API @"/CreditAccount/bill/detailBill/ios" //已还或未还账单详情


//推送id上传
#define RF_PushClientIdSend_API @"/getSendSn"

//兼职接口
#define RF_PositionSearch_API @"/job/v1/position/ios"
#define RF_JobList_API @"/job/v3/list/ios"
#define RF_JobShow_API @"/job/v3/show/ios"
#define RF_JobApply_API @"/job/v3/apply/ios"
#define RF_JobCheckStateSearch_API @"/job/v3/apply/show/ios"
#define RF_JobCancel_API @"/job/v3/cancel/ios"
#define RF_CardSign_API @"/job/v3/clickCard/ios"
#define RF_Comment_API @"/job/v3/comments/ios"
#define RF_Violate_API @"/job/v3/renege/ios"
#define RF_GETCITYINFO_API @"/job/v1/region/ios"
#define RF_CITYLIST_API @"/job/v1/city/ios"
#define RF_LockPunchURL_API  @"/#/job/checkin"
#define RF_LockCommentURL_API @"/#/job/review"

//认证接口
/**************************************************************************/
#define RF_AutheticationStatus_API @"audit/v2/read/status"
#define RF_StudentAuthInfo_API @"audit/v2/read"
#define RF_VideoAuthBook_API @"audit/v2/VideoPost"
#define RF_AuthComfirmSubmit_API @"audit/v2/ConfirmText"
#define RF_AuthImagePost_API @"audit/v2/imagePost"
#define RF_AuthStudentTextSubmit_API @"audit/v2/textPost"
/***************************************************************************/
#endif
