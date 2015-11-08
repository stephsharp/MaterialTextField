//
//  UIImage+MFTint.m
//  MaterialTextFieldDemo
//
//  Created by Steph Sharp on 6/08/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//
//  With thanks to Gordon Fontenot from thoughtbot:
//  https://robots.thoughtbot.com/designing-for-ios-blending-modes
//

#import "UIImage+MFTint.h"

@implementation UIImage (MFTint)

- (UIImage *)mf_tintedImageWithColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end
