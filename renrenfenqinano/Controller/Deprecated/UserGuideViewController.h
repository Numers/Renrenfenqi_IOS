//
//  UserGuideViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-12.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"

@interface UserGuideViewController : UIViewController <SGFocusImageFrameDelegate>
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgGuide;
- (IBAction)doStartAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@end
