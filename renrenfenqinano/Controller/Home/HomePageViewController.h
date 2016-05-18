//
//  HomePageViewController.h
//  renrenfenqi
//
//  Created by coco on 15-1-24.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SSZipArchive.h"

@interface HomePageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SGFocusImageFrameDelegate, UIAlertViewDelegate>
{
    NSUserDefaults* persistentDefaults;
}

@property (weak, nonatomic) IBOutlet UITableView *tableHome;

- (IBAction)doRepaymentAction:(id)sender;
- (IBAction)doWishListAction:(id)sender;
- (IBAction)doRedPacketAction:(id)sender;
- (IBAction)doPointsAction:(id)sender;
- (IBAction)doSearchAction:(id)sender;
- (IBAction)doLeftItemAction:(id)sender;
- (IBAction)doRightItemAction:(id)sender;
- (IBAction)doRight2ItemAction:(id)sender;

@property (strong, nonatomic) NSDictionary *updateResult;

@end
