//
//  MFAccessibilityElementProxy.m
//  MaterialTextField
//
//  Created by Adam Sharp on 17/12/2015.
//  Copyright © 2015 Stephanie Sharp. All rights reserved.
//

#import "MFAccessibilityElementProxy.h"

@implementation MFAccessibilityElementProxy

- (nonnull instancetype)initWithAccessibilityContainer:(nonnull id)container underlyingElement:(nonnull NSObject<UIAccessibilityIdentification> *)element
{
    self = [self initWithAccessibilityContainer:container];
    _underlyingElement = element;
    return self;
}

- (NSString *)accessibilityLabel
{
    return self.underlyingElement.accessibilityLabel;
}

- (NSString *)accessibilityHint
{
    return self.underlyingElement.accessibilityHint;
}

- (NSString *)accessibilityValue
{
    return self.underlyingElement.accessibilityValue;
}

- (NSString *)accessibilityIdentifier
{
    return self.underlyingElement.accessibilityIdentifier;
}

- (CGRect)accessibilityFrame
{
    return self.underlyingElement.accessibilityFrame;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return self.underlyingElement.accessibilityTraits;
}

@end
