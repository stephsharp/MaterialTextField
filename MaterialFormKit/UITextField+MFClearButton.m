//
//  UITextField+MFClearButton.m
//  MaterialFormKitDemo
//
//  Created by Steph Sharp on 11/08/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "UITextField+MFClearButton.h"

@implementation UITextField (MFClearButton)

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

@end
