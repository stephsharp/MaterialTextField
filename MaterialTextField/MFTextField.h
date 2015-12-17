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

/**
 * textPadding.height: Padding above and below the text field, between the placeholder label and underline.
 * textPadding.width:  Horizontal padding is yet to be implemented.
 */
@property (nonatomic) IBInspectable CGSize textPadding;

/**
 * Animate placeholder label above text field on focus or input (see placeholderAnimatesOnFocus).
 * Default is YES.
 */
@property (nonatomic) IBInspectable BOOL animatesPlaceholder;

/**
 * Default is NO. If YES, the placeholder label will animate up on focus rather than on text input.
 */
@property (nonatomic) IBInspectable BOOL placeholderAnimatesOnFocus;

/**
 * The color of the text field's default placeholder (displayed when text field is empty).
 */
@property (nonatomic) IBInspectable UIColor *defaultPlaceholderColor;

/**
 * The color of the placeholder label when the text field is not in focus.
 */
@property (nonatomic) IBInspectable UIColor *placeholderColor;

/**
 * Defaults to the first applicable font:
 * - the attributed placeholder font at the default placeholder size
 * - the text field font at the default placeholder size
 */
@property (nonatomic) UIFont *placeholderFont;

/**
 * The height of the underline when the text field is not in focus.
 */
@property (nonatomic) IBInspectable CGFloat underlineHeight;

/**
 * The height of the underline when the text field is in focus.
 */
@property (nonatomic) IBInspectable CGFloat underlineEditingHeight;

/**
 * The color of the underline when the text field is not in focus.
 */
@property (nonatomic) IBInspectable UIColor *underlineColor;

/**
 * To display an error under the text field, provide an NSError with a localized description.
 *
 * @param animated Set to YES to animate showing & hiding the error message.
 */
- (void)setError:(NSError *)error animated:(BOOL)animated;

/**
 * The error displayed under the text field.
 */
@property (nonatomic, readonly) NSError *error;

/**
 * The font for the error displayed under the text field.
 */
@property (nonatomic) UIFont *errorFont;

/**
 * The color of the error displayed under the text field.
 */
@property (nonatomic) IBInspectable UIColor *errorColor;

/**
 * The vertical padding between the underline and the error label.
 */
@property (nonatomic) IBInspectable CGFloat errorPadding;

@end
