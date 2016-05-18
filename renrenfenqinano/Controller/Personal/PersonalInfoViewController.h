//
//  PersonalInfoViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifierNickNameViewController.h"

@interface PersonalInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,ModifierNickNameDelegate>


@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@end
