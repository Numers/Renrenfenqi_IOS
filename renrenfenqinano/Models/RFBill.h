//
//  RFBill.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFBill : NSObject
@property(nonatomic, copy) NSString *typeName;
@property(nonatomic, copy) NSString *goodsName;
@property(nonatomic, copy) NSString *businessNo;
@property(nonatomic, copy) NSString *money;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, copy) NSString *nowPeriod;
@property(nonatomic, copy) NSString *periods;
@property(nonatomic, copy) NSString *billId;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *statusMsg;

-(void)setUpWithDic:(NSDictionary *)dic;
@end
