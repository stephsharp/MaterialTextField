//
//  MFTextField.h
//  MaterialTextField
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MFTextField : UITextField

@property (nonatomic) IBInspectable CGSize textPadding;

@property (nonatomic) IBInspectable BOOL animatesPlaceholder;

/**
 * Defaults to NO. If set to YES, placeholder will animate up on focus instead of on text input.
 */
@property (nonatomic) IBInspectable BOOL placeholderAnimatesOnFocus;

/**
 * Optional property to set the color of the textfield's default placeholder
 */
@property (nonatomic) IBInspectable UIColor *defaultPlaceholderColor;

@property (nonatomic) IBInspectable UIColor *placeholderColor;

/**
 * Defaults to the first applicable font:
 * - the attributed placeholder font at the default placeholder size
 * - the textField font at the default placeholder size
 */
@property (nonatomic) UIFont *placeholderFont;

@property (nonatomic) IBInspectable CGFloat underlineHeight;

@property (nonatomic) IBInspectable CGFloat underlineEditingHeight;

@property (nonatomic) IBInspectable UIColor *underlineColor;

/** 
 * The error message displayed under the text field is the NSError's localized description.
 */
@property (nonatomic) NSError *error;

@property (nonatomic) UIFont *errorFont;

@property (nonatomic) IBInspectable UIColor *errorColor;

@property (nonatomic) IBInspectable CGFloat errorPadding;

@end
