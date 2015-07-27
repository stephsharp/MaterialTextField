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

@property (nonatomic) IBInspectable CGSize labelPadding;
@property (nonatomic) IBInspectable CGFloat bottomPadding;

@property (nonatomic) IBInspectable BOOL floatingPlaceholderEnabled;
@property (nonatomic) IBInspectable UIColor *floatingPlaceholderColor;
@property (nonatomic) IBInspectable UIColor *floatingPlaceholderDisabledColor;
@property (nonatomic) UIFont *labelFont;

@property (nonatomic) IBInspectable CGFloat bottomBorderHeight;
@property (nonatomic) IBInspectable CGFloat bottomBorderEditingHeight;
@property (nonatomic) IBInspectable UIColor *bottomBorderColor;

@property (nonatomic) IBInspectable BOOL errorsEnabled;
@property (nonatomic) IBInspectable UIColor *errorColor;
@property (nonatomic) IBInspectable NSString *errorMessage;
@property (nonatomic) BOOL isValid;

@end
