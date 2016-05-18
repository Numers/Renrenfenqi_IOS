//
//  AddressSelectViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-10.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    省市区选择
 */

@protocol AddressSelectVCDelegate <NSObject>

- (void)AddressSelectVCDidDismisWithData:(NSObject *)data;

@end

@interface AddressSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)doBackAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableAddress;

@property (nonatomic, assign) id <AddressSelectVCDelegate> delegate;

@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSDictionary *params;

@end
