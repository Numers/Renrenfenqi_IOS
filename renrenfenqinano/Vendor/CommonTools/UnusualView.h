//
//  UnusualView.h
//  renrenfenqi
//
//  Created by DY on 15/2/2.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnusualView : UIView


@property (strong, nonatomic) NSString *messageStr;
@property (strong, nonatomic) UIImage *picImage;

- (void)refreshView;

@end
