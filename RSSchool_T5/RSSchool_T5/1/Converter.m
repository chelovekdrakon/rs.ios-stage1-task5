#import "Converter.h"
#import "NSPhoneFormatter.h"

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";

@interface PNConverter()

@property(strong, nonatomic) NSArray* countryCodes;
@property(strong, nonatomic) NSArray* countries;
@property(strong, nonatomic) NSCharacterSet* phoneCharacterSet;
@property(strong, nonatomic) NSDictionary* phoneNumbersLength;

@end


@implementation PNConverter

- (instancetype)init {
    self = [super init];
    if (self) {
        // @"77" should be before @"7" to avoid double match
        self.countryCodes = @[@"77", @"7", @"373", @"374", @"375", @"380", @"992", @"993", @"994", @"996", @"998"];
        self.countries    = @[@"KZ", @"RU",@"MD",  @"AM",  @"BY",  @"UA",  @"TJ",  @"TM",  @"AZ",  @"KG",  @"UZ"];
        self.phoneNumbersLength = @{
            @"KZ": @(10),
            @"RU": @(10),
            @"MD": @(8),
            @"AM": @(8),
            @"BY": @(9),
            @"UA": @(9),
            @"TJ": @(9),
            @"TM": @(8),
            @"AZ": @(9),
            @"KG": @(9),
            @"UZ": @(9)
        };
        
        self.phoneCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 +-#*()"];
    }
    
    return self;
}

- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    if(![_phoneCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]]) {
        return @{
            KeyPhoneNumber: string,
            KeyCountry: @""
        };
    }

    NSMutableString *country = [[NSMutableString alloc] init];
    NSMutableString *countryCode = [[NSMutableString alloc] init];

    for (int i = 0; i < _countryCodes.count; i++) {
        NSString *code = _countryCodes[i];
        if ([string hasPrefix:code]) {
            [country appendString:_countries[i]];
            [countryCode appendString:code];
            break;
        }
    }

    if (country.length) {
        NSString *phoneNumber = [self cutPhoneNumberFromString:string fromCountry:country withCountryCode:countryCode];
        NSString *formatteNumber = [self formatPhoneNumber:phoneNumber fromCountry:country withCountryCode:countryCode];
        
        return @{
            KeyPhoneNumber: formatteNumber,
            KeyCountry: country
        };
    }
    
    NSString *formattedString = [string hasPrefix:@"+"] ? string : [NSString stringWithFormat:@"+%@", string];
    NSString *cuttedFormattedString = formattedString.length > 13 ? [formattedString substringToIndex:13] : formattedString;

    return @{
        KeyPhoneNumber: cuttedFormattedString,
        KeyCountry: @""
    };
}

- (NSString *)formatPhoneNumber:(NSString *)phoneNumber fromCountry:(NSString *)country withCountryCode:(NSString *)countryCode {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSInteger expectedLength = [(NSNumber *)_phoneNumbersLength[country] integerValue];
    
    if (expectedLength == 10) {
        // +code (xxx) xxx xx xx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:3 and:3 and:2 and:@"-"]];
    } else if (expectedLength == 9) {
        // +code (xx) xxx-xx-xx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:2 and:3 and:2 and:@"-"]];
    } else if (expectedLength == 8) {
        //  +code (xx) xxx-xxx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:2 and:3 and:3 and:@"-"]];
    }
    
    return result;
}

- (NSString *)cutPhoneNumberFromString:(NSString *)phoneNumber fromCountry:(NSString *)country withCountryCode:(NSString *)countryCode {
    NSNumber *expectedLength = _phoneNumbersLength[country];
    NSUInteger countryCodeLength = [countryCode containsString:@"77"] ? 1 : countryCode.length;
    int lengthWithCode = expectedLength.doubleValue + countryCodeLength;
    
    return phoneNumber.length <= lengthWithCode ? phoneNumber : [phoneNumber substringToIndex:lengthWithCode];
}

@end
