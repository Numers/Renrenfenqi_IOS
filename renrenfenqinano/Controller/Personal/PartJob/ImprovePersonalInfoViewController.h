//
//  ImprovePersonalInfoViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/23.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SchoolListViewController.h"
#import "DateSelectionView.h" 

@interface ImprovePersonalInfoViewController : UIViewController <SchoolListDelegate,UITextFieldDelegate, DateSelectionViewDelegate>

@property (assign, nonatomic) BOOL isSkip;
@property (strong, nonatomic) Class theViewClass;

@end
