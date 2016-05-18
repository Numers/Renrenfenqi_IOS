//
//  RFBill.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFBill.h"

@implementation RFBill
-(void)setUpWithDic:(NSDictionary *)dic
{
    if (dic) {
        _typeName = [dic objectForKey:@"type_name"];
        _goodsName = [dic objectForKey:@"goods_name"];
        _businessNo = [dic objectForKey:@"business_no"];
        _money = [dic objectForKey:@"money"];
        _nowPeriod = [dic objectForKey:@"now_period"];
        _periods = [dic objectForKey:@"periods"];
        _billId = [dic objectForKey:@"bill_id"];
        _type = [dic objectForKey:@"type"];
        _statusMsg = [dic objectForKey:@"status_msg"];
    }
}
@end
