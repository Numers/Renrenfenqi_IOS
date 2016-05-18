//
//  NSString+MD5.m
//  ioshzxj
//
//  Created by 友旺 罗 on 12-7-31.
//  Copyright (c) 2012年 浙江莎彩科技有限公司. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

@implementation NSString (CryptoAdditions)
- (NSString *) md5_16
{
    const char *cStr = [self UTF8String];
    unsigned char result[MD5_LENGTH_16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    
    NSString* ret = @"";
    for (int i = 0; i < MD5_LENGTH_16; i++)
    {
        ret = [ret stringByAppendingFormat:@"%02x", result[i]];
    }
    
    return ret;
}

- (NSString *) md5_32
{
    const char *cStr = [self UTF8String];
    unsigned char result[MD5_LENGTH_32];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    
    NSString* ret = @"";
    for (int i = 0; i < MD5_LENGTH_32; i++)
    {
        ret = [ret stringByAppendingFormat:@"%02x", result[i]];
    }
    
    return ret; 
}

- (NSString *) stringByPaddingTheLeftToLength:(NSUInteger) newLength withString:(NSString *) padString startingAtIndex:(NSUInteger) padIndex
{
    if ([self length] <= newLength)
        return [[@"" stringByPaddingToLength:newLength - [self length] withString:padString startingAtIndex:padIndex] stringByAppendingString:self];
    else
        return [self copy];
}
@end

@implementation NSData (CryptoAdditions)
//- (NSString*)md5
//{
//    unsigned char result[16];
//    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
//    return [NSString stringWithFormat:
//            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3], 
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];  
//}

- (NSString*)md5_16
{
    unsigned char result[MD5_LENGTH_16];
    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
    
    NSString* ret = @"";
    for (int i = 0; i < MD5_LENGTH_16; i++)
    {
        ret = [ret stringByAppendingFormat:@"%02x", result[i]];
    }

    return ret;
}

- (NSString*)md5_32
{
    unsigned char result[MD5_LENGTH_32];
    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
    
    NSString* ret = @"";
    for (int i = 0; i < MD5_LENGTH_32; i++)
    {
        ret = [ret stringByAppendingFormat:@"%02x", result[i]];
    }
    
    return ret;
}
@end
