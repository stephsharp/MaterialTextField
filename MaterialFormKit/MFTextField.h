//
//  MFTextField.h
//  MaterialFormKit
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MFTextField : UITextField

@property (nonatomic) IBInspectable CGSize textPadding;

@property (nonatomic) IBInspectable BOOL placeholderEnabled;
@property (nonatomic) IBInspectable UIColor *placeholderColor;
//@property (nonatomic) IBInspectable UIColor *placeholderEditingColor; // defaults to tint color
//@property (nonatomic) IBInspectable UIColor *placeholderDisabledColor;
@property (nonatomic) UIFont *placeholderFont;

@property (nonatomic) IBInspectable CGFloat underlineHeight;
@property (nonatomic) IBInspectable CGFloat underlineEditingHeight;
@property (nonatomic) IBInspectable UIColor *underlineColor;
//@property (nonatomic) IBInspectable UIColor *underlineEditingColor; // defaults to tint color

@property (nonatomic) IBInspectable BOOL errorsEnabled;
@property (nonatomic) IBInspectable UIColor *errorColor;
@property (nonatomic) IBInspectable NSString *errorMessage;
@property (nonatomic) IBInspectable CGFloat errorPadding;
@property (nonatomic) UIFont *errorFont;
@property (nonatomic) BOOL isValid;

@end
