//
//  RFSelectCityViewController.h
//  renrenfenqi
//
//  Created by baolicheng on 15/7/16.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RFCity;
@protocol RFPartJobViewDelegate <NSObject>
-(void)selectCity:(RFCity *)selectCity;
@end
@interface RFSelectCityViewController : UIViewController
@property(nonatomic, assign) id<RFPartJobViewDelegate> delegate;
-(id)initWithGpsCity:(RFCity *)gCity;
@end
