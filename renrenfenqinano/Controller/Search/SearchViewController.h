//
//  SearchViewController.h
//  renrenfenqi
//
//  Created by wangjianxing on 14/12/7.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSUserDefaults* persistentDefaults;
}

- (IBAction)doBackAction:(id)sender;
- (IBAction)doSearchAction:(id)sender;
- (IBAction)doClearSearchHistory:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtKeyword;

@property (weak, nonatomic) IBOutlet UITableView *tableSearch;

@end
