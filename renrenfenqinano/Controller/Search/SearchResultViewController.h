//
//  SearchResultViewController.h
//  renrenfenqi
//
//  Created by coco on 14-12-8.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)doBackAction:(id)sender;
- (IBAction)doGoWishAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableResult;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) NSString *keyword;

@end