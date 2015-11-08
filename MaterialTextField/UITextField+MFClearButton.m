//
//  UITextField+MFClearButton.m
//  MaterialTextFieldDemo
//
//  Created by Steph Sharp on 11/08/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextField+MFClearButton.h"
#import "UIImage+MFTint.h"

static const void *const MFTintedClearImage = &MFTintedClearImage;

@interface UITextField ()
@property (nonatomic, setter=mf_setTintedClearImage:) UIImage *mf_tintedClearImage;
@end

@implementation UITextField (MFClearButton)

- (void)mf_tintClearButton
{
    UIButton *clearButton = [self mf_clearButton];
    UIImage *highlightedClearImage = [clearButton imageForState:UIControlStateHighlighted];

    if (highlightedClearImage) {
        if (!self.mf_tintedClearImage) {
            self.mf_tintedClearImage = [highlightedClearImage mf_tintedImageWithColor:self.tintColor];
        }
        [clearButton setImage:self.mf_tintedClearImage forState:UIControlStateHighlighted];
    }
}

- (UIButton *)mf_clearButton
{
    UIButton *button;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            button = (UIButton *)view;
        }
    }
    return button;
}

- (UIImage *)mf_tintedClearImage
{
    return objc_getAssociatedObject(self, MFTintedClearImage);
}

- (void)mf_setTintedClearImage:(UIImage *)image
{
    objc_setAssociatedObject(self, MFTintedClearImage, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
