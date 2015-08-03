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

    self.rightAlignedTextField.shouldAnimatePlaceholder = NO;
    self.rightAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.rightAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];
    self.rightAlignedTextField.errorsEnabled = YES;
    self.rightAlignedTextField.error = @"Maximum of 6 characters allowed.";

    self.leftAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.leftAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];
    self.leftAlignedTextField.errorsEnabled = YES;
    self.leftAlignedTextField.error = @"This is an error message that is really long and should wrap onto 2 or more lines.";
}

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField == self.rightAlignedTextField) {
        self.rightAlignedTextField.isValid = (newString.length <= 6);
    }
    else if (textField == self.leftAlignedTextField) {
        self.leftAlignedTextField.isValid = (newString.length < 2);
    }

    return YES;
}

@end
