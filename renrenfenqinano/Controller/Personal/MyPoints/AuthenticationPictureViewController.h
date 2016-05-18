//
//  AuthenticationPictureViewController.h
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticationPictureViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIButton *identityCardBtn;
@property (weak, nonatomic) IBOutlet UIButton *studentIDBtn;

@end
