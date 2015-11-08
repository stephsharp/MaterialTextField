//
//  UIFont+MaterialTextField.m
//  MaterialTextField
//
//  Created by Steph Sharp on 8/11/2015.
//  Copyright © 2015 Stephanie Sharp. All rights reserved.
//

#import "UIFont+MaterialTextField.h"

@implementation UIFont (MaterialTextField)

- (BOOL)isEqual:(UIFont *)font
{
    return [[[self fontDescriptor] fontAttributes] isEqual:[[font fontDescriptor] fontAttributes]];
}

@end
