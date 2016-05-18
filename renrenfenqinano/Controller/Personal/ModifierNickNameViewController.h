//
//  ModifierNickNameViewController.h
//  renrenfenqi
//
//  Created by DY on 14/12/3.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModifierNickNameDelegate <NSObject>

- (void)saveNewNickName:(NSString *)name;

@end

@interface ModifierNickNameViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSString *nickNameString;
@property (weak, nonatomic) id<ModifierNickNameDelegate> delegate;

@end
