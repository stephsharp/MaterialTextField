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

@property (nonatomic) IBInspectable CGSize padding;
@property (nonatomic) IBInspectable BOOL floatingLabelEnabled;
@property (nonatomic) IBInspectable CGFloat floatingLabelBottomMargin;
@property (nonatomic) IBInspectable UIFont *floatingLabelFont;
@property (nonatomic) IBInspectable UIColor *floatingLabelColor;
@property (nonatomic) IBInspectable CGFloat bottomBorderHeight;
@property (nonatomic) IBInspectable UIColor *bottomBorderColor;
@property (nonatomic) IBInspectable CGFloat bottomBorderHighlightedHeight;

@end
