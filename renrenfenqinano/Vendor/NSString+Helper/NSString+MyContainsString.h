//
//  NSString+MyContainsString.h
//  GuoZhongBao
//
//  Created by coco on 15-6-22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyContainsString)

- (BOOL)myContainsString:(NSString *)string;
- (NSString *)urlencode;
@end
