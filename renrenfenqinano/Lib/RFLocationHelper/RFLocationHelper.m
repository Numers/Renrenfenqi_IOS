//
//  RFLocationHelper.m
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "RFLocationHelper.h"
#import "RFCity.h"
#import "RFPartJobManager.h"
static RFLocationHelper *rfLocationHelper;
@implementation RFLocationHelper
+(id)defaultHelper
{
    if (rfLocationHelper == nil) {
        rfLocationHelper = [[RFLocationHelper alloc] init];
    }
    return rfLocationHelper;
}

-(void)startLocation
{
    [self requestCityInfoWithCityName:@"杭州" IsIndex:YES];//默认为杭州
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1000.0f;
        [locationManager startUpdatingLocation];
    }
}

-(void)stopLocation
{
    if (locationManager) {
        [locationManager stopUpdatingLocation];
    }
}

-(BOOL)isCityOpen
{
    BOOL result = NO;
    if (city) {
        if (cityStatus == 0) {
            result = NO;
        }
        
        if (cityStatus == 1) {
            result = YES;
        }
    }else{
        result = NO;
    }
    return result;
}

-(RFCity *)returnGPSCity
{
    return city;
}

-(RFCity *)returnIndexCity
{
    return indexCity;
}

-(void)requestCityInfoWithCityName:(NSString *)cityName IsIndex:(BOOL)isindex
{
    [[RFPartJobManager defaultManager] requestCityInfoWithCityName:cityName Success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDic = (NSDictionary *)responseObject;
        if (resultDic) {
            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
            if (dataDic) {
                if (isindex) {
                    indexCity = [[RFCity alloc] init];
                    indexCity.cityId = [[dataDic objectForKey:@"id"] integerValue];
                    indexCity.cityName = [dataDic objectForKey:@"name"];
                }else{
                    city = [[RFCity alloc] init];
                    city.cityId = [[dataDic objectForKey:@"id"] integerValue];
                    city.cityName = [dataDic objectForKey:@"name"];
                    cityStatus = [[dataDic objectForKey:@"state"] integerValue];
                    [self deliveryLocationInfo];
                }
            }
        }
    } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self deliveryLocationInfo];
    } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self deliveryLocationInfo];
    }];
}

-(void)deliveryLocationInfo
{
    if (city) {
        NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",lat],@"lat",[NSString stringWithFormat:@"%f",lng],@"lng", nil];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"client",locationDic,@"location",[NSString stringWithFormat:@"%ld",(long)city.cityId],@"cityID",city.cityName,@"cityName", nil];
        if ([self.delegate respondsToSelector:@selector(returnLocationDictionaryInfo:)]) {
            [self.delegate returnLocationDictionaryInfo:dic];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(returnLocationDictionaryInfo:)]) {
            [self.delegate returnLocationDictionaryInfo:nil];
        }
    }
}

-(NSDictionary *)returnLocaitonInfo
{
    NSDictionary *dic;
    if (city) {
        if ([self isCityOpen]) {
            NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",lat],@"lat",[NSString stringWithFormat:@"%f",lng],@"lng", nil];
            dic = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"client",locationDic,@"location",[NSString stringWithFormat:@"%ld",(long)city.cityId],@"cityID",city.cityName,@"cityName", nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"当前城市%@未开通相关业务",city.cityName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"120.121414"],@"lat",[NSString stringWithFormat:@"30.29777"],@"lng", nil];
            dic = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"client",locationDic,@"location",[NSString stringWithFormat:@"%ld",(long)indexCity.cityId],@"cityID",indexCity.cityName,@"cityName", nil];
        }
    }else{
        if (indexCity) {
            NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"120.121414"],@"lat",[NSString stringWithFormat:@"30.29777"],@"lng", nil];
            dic = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"client",locationDic,@"location",[NSString stringWithFormat:@"%ld",(long)indexCity.cityId],@"cityID",indexCity.cityName,@"cityName", nil];
        }else{
            dic = nil;
        }
    }
    return dic;
}

#pragma -mark CLLocaitonManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    if (location.horizontalAccuracy == -1) {
        [manager stopUpdatingLocation];
        [self startLocation];
    }else{
        [manager stopUpdatingLocation];
        NSLog(@"%.2f,%.2f",location.coordinate.latitude,location.coordinate.longitude);
        lat = location.coordinate.latitude;
        lng = location.coordinate.longitude;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *locality = placemark.locality;
                if (!locality) {
                    //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                    locality = placemark.administrativeArea;
                }
                NSString *currentCity = [locality stringByReplacingOccurrencesOfString:@"市" withString:@""];
                //                        NSString *state = placemark.administrativeArea;
                //                        NSString *area = placemark.subLocality;
                [self requestCityInfoWithCityName:currentCity IsIndex:NO];
            }
        }];

    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
    [manager stopUpdatingLocation];
}

@end
