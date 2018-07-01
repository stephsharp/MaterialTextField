//
//  MaterialTextFieldDemoViewController.m
//  MaterialTextFieldDemo
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import <MaterialTextField/MaterialTextField.h>
#import "MaterialTextFieldDemoViewController.h"

NSString *const MFDemoErrorDomain = @"MFDemoErrorDomain";
NSInteger const MFDemoErrorCode = 100;

@interface MaterialTextFieldDemoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MFTextField *textField1;
@property (weak, nonatomic) IBOutlet MFTextField *textField2;
@property (weak, nonatomic) IBOutlet MFTextField *textField4;
@property (weak, nonatomic) IBOutlet MFTextField *textField5;

@end

@implementation MaterialTextFieldDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTextField1];
    [self setupTextField2];
    [self setupTextField4];
    [self setupTextField5];
}

#pragma mark - Setup

- (void)setupTextField1
{
    self.textField1.animatesPlaceholder = NO;
    self.textField1.tintColor = [UIColor mf_greenColor];
    self.textField1.textColor = [UIColor mf_veryDarkGrayColor];
}

- (void)setupTextField2
{
    self.textField2.tintColor = [UIColor mf_greenColor];
    self.textField2.textColor = [UIColor mf_veryDarkGrayColor];
    self.textField2.defaultPlaceholderColor = [UIColor mf_darkGrayColor];
    self.textField2.placeholderAnimatesOnFocus = YES;

    UIFontDescriptor * fontDescriptor = [self.textField2.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:self.textField2.font.pointSize];

    self.textField2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Attributed placeholder" attributes:@{NSFontAttributeName:font}];
}

- (void)setupTextField4
{
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eyeButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    eyeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    eyeButton.bounds = CGRectMake(0, 0, 24, 16);
    [eyeButton addTarget:self
                  action:@selector(togglePassword)
        forControlEvents:UIControlEventTouchUpInside];
    
    self.textField4.rightViewMode = UITextFieldViewModeAlways;
    self.textField4.rightView = eyeButton;
    
    UIImageView *lockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    lockImage.bounds = CGRectMake(0, 0, 24, 16);
    lockImage.contentMode = UIViewContentModeLeft;
    self.textField4.leftViewMode = UITextFieldViewModeAlways;
    self.textField4.leftView = lockImage;
}

- (void)togglePassword
{
    self.textField4.secureTextEntry = !self.textField4.isSecureTextEntry;
}

- (void)setupTextField5
{
    [self validateTextField5Animated:NO];
}

#pragma mark - Actions

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.textField1) {
        [self validateTextField1];
    }
    else if (textField == self.textField2) {
        [self validateTextField2];
    }
    else if (textField == self.textField4) {
        [self validateTextField4];
    }
    else if (textField == self.textField5) {
        [self validateTextField5Animated:YES];
    }
}

#pragma mark - Text field validation

- (void)validateTextField1
{
    NSError *error = nil;
    if (![self textField1IsValid]) {
        error = [self errorWithLocalizedDescription:@"Maximum of 6 characters allowed."];
    }
    [self.textField1 setError:error animated:YES];
}

- (void)validateTextField2
{
    NSError *error = nil;
    if (![self textField2IsValid]) {
        error = [self errorWithLocalizedDescription:@"This is an error message that is really long and should wrap onto 2 or more lines."];
    }
    [self.textField2 setError:error animated:YES];
}

- (void)validateTextField4
{
    NSError *error = nil;
    if (![self textField4IsValid]) {
        error = [self errorWithLocalizedDescription:@"Password must be less than 16 characters."];
    }
    [self.textField4 setError:error animated:YES];
}

- (void)validateTextField5Animated:(BOOL)animated
{
    NSError *error = nil;
    if (![self textField5IsValid]) {
        error = [self errorWithLocalizedDescription:@"An error message"];
    }
    [self.textField5 setError:error animated:animated];
}

- (BOOL)textField1IsValid
{
    return self.textField1.text.length <= 6;
}

- (BOOL)textField2IsValid
{
    return self.textField2.text.length < 3;
}

- (BOOL)textField4IsValid
{
    return self.textField4.text.length < 16;
}

- (BOOL)textField5IsValid
{
    return self.textField5.text.length > 0;
}

- (NSError *)errorWithLocalizedDescription:(NSString *)localizedDescription
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: localizedDescription};
    return [NSError errorWithDomain:MFDemoErrorDomain code:MFDemoErrorCode userInfo:userInfo];
}

@end
