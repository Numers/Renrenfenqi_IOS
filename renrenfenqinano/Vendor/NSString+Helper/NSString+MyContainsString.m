//
//  NSString+MyContainsString.m
//  GuoZhongBao
//
//  Created by coco on 15-6-22.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "NSString+MyContainsString.h"

@implementation NSString (MyContainsString)

/**
    可以兼容IOS7的字符串是否包含方法
 */
- (BOOL)myContainsString:(NSString*)string {
    NSRange range = [self rangeOfString:string];
    return range.length != 0;
}

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
