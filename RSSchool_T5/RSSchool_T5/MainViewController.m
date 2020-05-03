//
//  MainViewController.m
//  RSSchool_T5
//
//  Created by Фёдор Морев on 5/3/20.
//  Copyright © 2020 iOSLab. All rights reserved.
//

#import "MainViewController.h"
#import "NSPhoneFormatter.h"

@interface MainViewController ()

@property(weak, nonatomic) UIView* mainView;
@property(weak, nonatomic) UIImageView* flagImageView;
@property(weak, nonatomic) UITextField* textField;

@property(strong, nonatomic) NSArray* countryCodes;
@property(strong, nonatomic) NSArray* countries;
@property(strong, nonatomic) NSCharacterSet* phoneCharacterSet;
@property(strong, nonatomic) NSDictionary* phoneNumbersLength;

@end

@implementation MainViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = self.view.bounds.size.width;
    
    CGFloat mainViewWidth = screenWidth - 50;
    CGFloat mainViewHeight = 100;
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(25, 100, mainViewWidth, mainViewHeight)];
    self.mainView = mainView;
    
    _mainView.layer.borderWidth = 1.f;
    _mainView.layer.borderColor = [UIColor blackColor].CGColor;
    _mainView.layer.cornerRadius = 5;

    [self.view addSubview:_mainView];
    
    CGFloat flagImageViewWidth = 50;
    CGFloat flagImageViewHeight = mainViewHeight - 50;
    CGFloat flagImageViewMargin = 10;
    
    UIImageView* flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(flagImageViewMargin, 25, flagImageViewWidth, flagImageViewHeight)];
    self.flagImageView = flagImageView;
    
    _flagImageView.layer.borderWidth = 1.f;
    _flagImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _flagImageView.layer.cornerRadius = 2;
    
    [_mainView addSubview:_flagImageView];
    
    
    CGFloat textFieldpositionX = (_flagImageView.center.x + (_flagImageView.layer.frame.size.width / 2)) + flagImageViewMargin;
    CGFloat textFieldMarginRight = 10;
    CGFloat textFieldWidht = mainViewWidth - flagImageViewWidth - (flagImageViewMargin * 2) - textFieldMarginRight;
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldpositionX, 25, textFieldWidht, mainViewHeight - 50)];
    self.textField = textField;
    
    _textField.keyboardType = UIKeyboardTypePhonePad;
    _textField.textContentType = UITextContentTypeTelephoneNumber;
    [self setTextFieldBorder:_textField];
    
    _textField.delegate = (id)self;
    
    [_mainView addSubview:_textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(![_phoneCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]]) {
        return NO;
    }
    
    BOOL result = NO;
    
    NSString *textFieldValue = string.length
        ? [NSString stringWithFormat:@"%@%@", textField.text, string]
        : [textField.text substringToIndex:(textField.text.length - range.length)];
    
    NSString *textFieldPhoneNumber = [NSPhoneFormatter getPhoneNumberWithoutFormatting:textFieldValue];
    
    NSMutableString *country = [[NSMutableString alloc] init];
    NSMutableString *countryCode = [[NSMutableString alloc] init];
    
    for (int i = 0; i < _countryCodes.count; i++) {
        NSString *code = _countryCodes[i];
        if ([textFieldPhoneNumber hasPrefix:code]) {
            [country appendString:_countries[i]];
            [countryCode appendString:code];
            break;
        }
    }
    
    if (country.length) {
        if (country.length < 4) {
            _flagImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"flag_%@", country]];
        }
        
        BOOL isLengthValid = [self validatePhoneLength:textFieldPhoneNumber fromCountry:country withCountryCode:countryCode];
        
        if (isLengthValid) {
            [self formatTextField:textFieldPhoneNumber fromCountry:country withCountryCode:countryCode];
        }
    } else {
        _flagImageView.image = nil;
        
        if (textFieldPhoneNumber.length <= 12) {
            result = YES;
        }
    }
    
    return result;
}

- (BOOL)validatePhoneLength:(NSString *)phoneNumber fromCountry:(NSString *)country withCountryCode:(NSString *)countryCode {
    NSNumber *expectedLength = _phoneNumbersLength[country];
    return phoneNumber.length <= (expectedLength.doubleValue + countryCode.length);
}

- (void)formatTextField:(NSString *)phoneNumber fromCountry:(NSString *)country withCountryCode:(NSString *)countryCode {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSInteger expectedLength = [(NSNumber *)_phoneNumbersLength[country] integerValue];
    
    if (expectedLength == 10) {
        // +code (xxx) xxx xx xx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:3 and:3 and:2 and:@" "]];
    } else if (expectedLength == 9) {
        // +code (xx) xxx-xx-xx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:2 and:3 and:2 and:@"-"]];
    } else if (expectedLength == 8) {
        //  +code (xx) xxx-xxx
        [result appendString:[NSPhoneFormatter formatPhoneNumber:phoneNumber withCountryCode:countryCode where:2 and:3 and:3 and:@"-"]];
    }
    
    _textField.text = result;
}

- (void)setTextFieldBorder:(UITextField *)textField {
    CALayer *border = [CALayer layer];
    
    CGFloat borderWidth = 2;
    
    border.borderColor = [UIColor blackColor].CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    textField.layer.masksToBounds = YES;
    
    [textField.layer addSublayer:border];
}

@end
