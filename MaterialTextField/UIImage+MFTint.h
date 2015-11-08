//
//  UIImage+MFTint.h
//  MaterialTextFieldDemo
//
//  Created by Steph Sharp on 6/08/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//
//  With thanks to Gordon Fontenot from thoughtbot:
//  https://robots.thoughtbot.com/designing-for-ios-blending-modes
//

#import <UIKit/UIKit.h>

@interface UIImage (MFTint)

- (UIImage *)mf_tintedImageWithColor:(UIColor *)tintColor;

@end
