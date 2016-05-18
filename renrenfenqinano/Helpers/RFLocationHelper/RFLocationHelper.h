//
//  RFLocationHelper.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class RFCity;
@protocol RFLocationHelperDelegate <NSObject>
-(void)returnLocationDictionaryInfo:(NSDictionary *)dic;
@end
@interface RFLocationHelper : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    float lat;
    float lng;
    RFCity *city;
    RFCity *indexCity;
    NSInteger cityStatus;
}
@property(nonatomic, assign) id<RFLocationHelperDelegate> delegate;

+(id)defaultHelper;
-(void)startLocation;
-(BOOL)isCityOpen;
-(RFCity *)returnGPSCity;
-(RFCity *)returnIndexCity;
-(NSDictionary *)returnLocaitonInfo;
@end
