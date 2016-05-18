//
//  CommentViewController.h
//  renrenfenqi
//
//  Created by DY on 15/1/13.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomKeyboard.h"

@interface CommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomKeyboardDelegate>

@property (strong, nonatomic) NSString *activityID;

@end
