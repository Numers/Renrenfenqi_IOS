//
//  MyBillsOrderDetailViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    账单中的订单明细
 */

@interface MyBillsOrderDetailViewController : UIViewController
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *orderArr;

@end
