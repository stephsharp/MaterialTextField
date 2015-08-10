//
//  MaterialFormKitDemoViewController.m
//  MaterialFormKitDemo
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "MaterialFormKitDemoViewController.h"
#import "UIColor+MaterialFormKit.h"
#import "MFTextField.h"

@interface MaterialFormKitDemoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MFTextField *rightAlignedTextField;
@property (weak, nonatomic) IBOutlet MFTextField *leftAlignedTextField;

@end

@implementation MaterialFormKitDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rightAlignedTextField.animatesPlaceholder = NO;
    self.rightAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.rightAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];

    self.leftAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.leftAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];
    self.leftAlignedTextField.defaultPlaceholderColor = [UIColor mf_darkGrayColor];
    self.leftAlignedTextField.placeholderAnimatesOnFocus = YES;

    UIFontDescriptor * fontDescriptor = [self.leftAlignedTextField.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:self.leftAlignedTextField.font.pointSize];
    self.leftAlignedTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Attributed placeholder" attributes:@{NSFontAttributeName:font}];
}

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateTextField:textField withString:newString];

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // Need to clear text here so textField:shouldChangeCharactersInRange:replacementString:
    // is not called with autocorrection suggestion after text has been cleared.
    textField.text = nil;

    [self updateTextField:textField withString:nil];
    return YES;
}

- (void)updateTextField:(UITextField *)textField withString:(NSString *)string
{
    if (textField == self.rightAlignedTextField) {
        NSString *error = @"Maximum of 6 characters allowed.";
        self.rightAlignedTextField.error = (string.length > 6) ? error : nil;
    }
    else if (textField == self.leftAlignedTextField) {
        NSString *error = @"This is an error message that is really long and should wrap onto 2 or more lines.";
        self.leftAlignedTextField.error = (string.length >= 2) ? error : nil;
    }
}

@end
