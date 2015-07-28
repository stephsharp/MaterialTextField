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

@interface MaterialFormKitDemoViewController ()

@property (weak, nonatomic) IBOutlet MFTextField *rightAlignedTextField;
@property (weak, nonatomic) IBOutlet MFTextField *leftAlignedTextField;

@end

@implementation MaterialFormKitDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rightAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.rightAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];

    self.leftAlignedTextField.tintColor = [UIColor mf_greenColor];
    self.leftAlignedTextField.textColor = [UIColor mf_veryDarkGrayColor];
    self.leftAlignedTextField.errorsEnabled = YES;
    self.leftAlignedTextField.isValid = NO;
    //self.leftAlignedTextField.errorMessage = @"This is an error message that is really long and should wrap onto 2 lines.";
}

- (IBAction)dismissKeyboard
{
    [self.view endEditing:YES];
}

@end
