//
//  NSString+MD5.h
//  ioshzxj
//
//  Created by 友旺 罗 on 12-7-31.
//  Copyright (c) 2012年 浙江莎彩科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MD5_LENGTH_16    16
#define MD5_LENGTH_32    32

@interface NSString (CryptoAdditions)
- (NSString *) md5_16;
- (NSString *) md5_32;

- (NSString *) stringByPaddingTheLeftToLength:(NSUInteger) newLength withString:(NSString *) padString startingAtIndex:(NSUInteger) padIndex;
@end

@interface NSData (CryptoAdditions)
- (NSString *) md5_16;
- (NSString *) md5_32;
@end
