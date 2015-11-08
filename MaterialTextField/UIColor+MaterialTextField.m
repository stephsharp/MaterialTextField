//
//  UIColor+MaterialTextField.m
//  MaterialTextField
//
//  Created by Steph Sharp on 22/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "UIColor+MaterialTextField.h"

@implementation UIColor (MaterialTextField)

+ (UIColor *)colorWithHex:(int)hex
{
    return [UIColor colorWithRed:((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0f
                           green:((CGFloat)((hex & 0x00FF00) >> 8)) / 255.0f
                            blue:((CGFloat)((hex & 0x0000FF) >> 0)) / 255.0f
                           alpha:1.0];
}

+ (UIColor *)mf_defaultPlaceholderGray
{
    return [UIColor colorWithRed:0.0f green:0.0f blue:0.098f alpha:0.22f];
}

+ (UIColor *)mf_veryDarkGrayColor
{
    return [UIColor colorWithHex:0x222222];
}

+ (UIColor *)mf_darkGrayColor
{
    return [UIColor colorWithHex:0x666666];
}

+ (UIColor *)mf_midGrayColor
{
    return [UIColor colorWithHex:0x999999];
}

+ (UIColor *)mf_lightGrayColor
{
    return [UIColor colorWithHex:0xBBBBBB];
}

+ (UIColor *)mf_greenColor
{
    return [UIColor colorWithHex:0x29A39C];
}

+ (UIColor *)mf_redColor
{
    return [UIColor colorWithHex:0xED1C29];
}

@end
