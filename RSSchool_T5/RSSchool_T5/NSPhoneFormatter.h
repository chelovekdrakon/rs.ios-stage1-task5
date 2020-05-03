//
//  NSPhoneFormatter.h
//  RSSchool_T5
//
//  Created by Фёдор Морев on 5/3/20.
//  Copyright © 2020 iOSLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPhoneFormatter : NSObject

+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber
                withCountryCode:(NSString *)countryCode
                          where:(int)subCodeLength
                            and:(int)firstBlockLength
                            and:(int)secondBlockLength
                            and:(NSString *)divider;

+ (NSString *)getPhoneNumberWithoutFormatting:(NSString *)str;

@end
