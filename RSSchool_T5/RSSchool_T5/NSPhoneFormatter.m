//
//  NSPhoneFormatter.m
//  RSSchool_T5
//
//  Created by Фёдор Морев on 5/3/20.
//  Copyright © 2020 iOSLab. All rights reserved.
//

#import "NSPhoneFormatter.h"

@implementation NSPhoneFormatter

+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber
                withCountryCode:(NSString *)countryCode
                          where:(int)subCodeLength
                            and:(int)firstBlockLength
                            and:(int)secondBlockLength
                            and:(NSString *)divider {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSUInteger inputLength = phoneNumber.length;
    NSUInteger codeLength = [countryCode containsString:@"77"] ? 1 : countryCode.length;
    
    if (inputLength <= codeLength) {
        [result appendString:[NSString stringWithFormat:@"+%@", phoneNumber]];
    } else if (inputLength <= codeLength + subCodeLength) {
        NSString *code = [phoneNumber substringToIndex:codeLength];
        NSString *subCode = [phoneNumber substringFromIndex:codeLength];
        [result appendString:[NSString stringWithFormat:@"+%@ (%@", code, subCode]];
    } else if (inputLength <= codeLength + subCodeLength + firstBlockLength) {
        NSString *code = [phoneNumber substringToIndex:codeLength];
        NSString *subCode = [phoneNumber substringWithRange:NSMakeRange(codeLength, subCodeLength)];
        NSString *firstBlock = [phoneNumber substringFromIndex:(codeLength + subCodeLength)];
        NSString *str = [NSString stringWithFormat:@"+%@ (%@) %@", code, subCode, firstBlock];
        [result appendString:str];
    } else if (inputLength <= codeLength + subCodeLength + firstBlockLength + secondBlockLength) {
        NSString *code = [phoneNumber substringToIndex:codeLength];
        NSString *subCode = [phoneNumber substringWithRange:NSMakeRange(codeLength, subCodeLength)];
        NSString *firstBlock = [phoneNumber substringWithRange:NSMakeRange(codeLength + subCodeLength, firstBlockLength)];
        NSString *secondBLock = [phoneNumber substringFromIndex:(codeLength + subCodeLength + firstBlockLength)];
        NSString *str = [NSString stringWithFormat:@"+%@ (%@) %@%@%@", code, subCode, firstBlock, divider, secondBLock];
        [result appendString:str];
    } else {
        NSString *code = [phoneNumber substringToIndex:codeLength];
        NSString *subCode = [phoneNumber substringWithRange:NSMakeRange(codeLength, subCodeLength)];
        NSString *firstBlock = [phoneNumber substringWithRange:NSMakeRange(codeLength + subCodeLength, firstBlockLength)];
        NSString *secondBLock = [phoneNumber substringWithRange:NSMakeRange(codeLength + subCodeLength + firstBlockLength, secondBlockLength)];
        NSString *thirdBlock = [phoneNumber substringFromIndex:(codeLength + subCodeLength + firstBlockLength + secondBlockLength)];
        NSString *str = [NSString stringWithFormat:@"+%@ (%@) %@%@%@%@%@", code, subCode, firstBlock, divider, secondBLock, divider, thirdBlock];
        [result appendString:str];
    }
    
    return result;
}

+ (NSString *)getPhoneNumberWithoutFormatting:(NSString *)str {
    NSError *error = NULL;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSString *subStr = [str substringWithRange:matchRange];
        [result appendString:subStr];
    }
    
    return result;
}

@end
