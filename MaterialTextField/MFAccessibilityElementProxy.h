//
//  MFAccessibilityElementProxy.h
//  MaterialTextField
//
//  Created by Adam Sharp on 17/12/2015.
//  Copyright © 2015 Stephanie Sharp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MFAccessibilityElementProxy : UIAccessibilityElement

@property (nonatomic, readonly) NSObject<UIAccessibilityIdentification> *underlyingElement;

- (instancetype)initWithAccessibilityContainer:(id)container underlyingElement:(NSObject<UIAccessibilityIdentification> *)element;

@end

NS_ASSUME_NONNULL_END
