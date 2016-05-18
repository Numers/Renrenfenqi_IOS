//
//  MyBillsAutoRepaymentOKViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-11.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    代扣设置成功后
 */


@interface MyBillsAutoRepaymentOKViewController : UIViewController
- (IBAction)doMyBillsAction:(id)sender;
- (IBAction)doGoAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblBankName;
@property (weak, nonatomic) IBOutlet UILabel *lblBankTrail;
@property (weak, nonatomic) IBOutlet UILabel *lblBankHolder;

@property (strong, nonatomic) NSDictionary *bankInfo;

@end
