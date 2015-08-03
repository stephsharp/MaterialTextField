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

    self.leftAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.leftAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];
}

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField == self.rightAlignedTextField) {
        NSString *error = @"Maximum of 6 characters allowed.";
        self.rightAlignedTextField.error = (newString.length > 6) ? error : nil;
    }
    else if (textField == self.leftAlignedTextField) {
        NSString *error = @"This is an error message that is really long and should wrap onto 2 or more lines.";
        self.leftAlignedTextField.error = (newString.length >= 2) ? error : nil;
    }

    return YES;
}

@end
