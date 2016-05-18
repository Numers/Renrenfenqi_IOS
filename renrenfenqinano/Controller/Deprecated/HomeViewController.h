//
//  FirstViewController.h
//  renrenfenqinano
//
//  Created by coco on 14-11-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"

@interface HomeViewController : UIViewController <SGFocusImageFrameDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doGoSearch:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *hotView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *themeTitle;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeiConstraint;


@end

