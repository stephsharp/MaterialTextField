//
//  MFTextField.m
//  MaterialFormKit
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "MFTextField.h"
#import "UIColor+MaterialFormKit.h"

@interface MFTextField ()

@property (nonatomic) UILabel *floatingLabel;
@property (nonatomic) CALayer *bottomBorderLayer;

@end

@implementation MFTextField

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    [self setDefaults];
    [self setupBottomBorder];
    [self setupFloatingLabel];

    self.borderStyle = UITextBorderStyleNone;
}

#pragma mark - Setup

- (void)setDefaults
{
    self.padding = CGSizeMake(0.0f, 5.0f);

    self.floatingLabelEnabled = YES;
    self.floatingLabelBottomMargin = 2.0f;
    self.floatingLabelColor = [UIColor mf_darkGrayColor];
    self.floatingLabelDisabledColor = [UIColor mf_midGrayColor];
    self.floatingLabelFont = [self defaultFloatingLabelFont];

    self.bottomBorderHeight = 1.0f;
    self.bottomBorderColor = [UIColor mf_lightGrayColor];
    self.bottomBorderEditingHeight = 1.75f;

    self.errorColor = [UIColor mf_redColor];
}

- (void)setupBottomBorder
{
    self.bottomBorderLayer = [CALayer layer];
    self.bottomBorderLayer.frame = CGRectMake(0, self.layer.bounds.size.height - 1,
                                              self.layer.bounds.size.width, 1);
    self.bottomBorderLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.bottomBorderLayer];
}

- (void)setupFloatingLabel
{
    self.floatingLabel = [UILabel new];
    self.floatingLabel.font = self.floatingLabelFont;
    self.floatingLabel.alpha = 0.0f;
    [self updateFloatingLabelText];
    [self addSubview:self.floatingLabel];
}

#pragma mark - Properties

- (void)setFloatingLabelFont:(UIFont *)floatingLabelFont
{
    _floatingLabelFont = floatingLabelFont;
    self.floatingLabel.font = floatingLabelFont;
}

- (void)setFloatingLabelColor:(UIColor *)floatingLabelColor
{
    _floatingLabelColor = floatingLabelColor;
    self.floatingLabel.textColor = floatingLabelColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self updateFloatingLabelText];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.floatingLabelEnabled) {
        if (![self isEmpty]) {
            self.floatingLabel.textColor = self.isFirstResponder ? self.tintColor : self.floatingLabelColor;
            if (self.floatingLabel.alpha == 0.0f) {
                [self showFloatingLabel];
            }
        }
        else {
            [self hideFloatingLabel];
        }
    }

    self.bottomBorderLayer.backgroundColor = self.isFirstResponder ? self.tintColor.CGColor : self.bottomBorderColor.CGColor;
    CGFloat borderHeight = self.isFirstResponder ? self.bottomBorderEditingHeight : self.bottomBorderHeight;
    self.bottomBorderLayer.frame = CGRectMake(0, self.layer.bounds.size.height - borderHeight,
                                              self.layer.bounds.size.width, borderHeight);
}

#pragma mark - Floating placeholder label

- (UIFont *)defaultFloatingLabelFont
{
    UIFontDescriptor * fontDescriptor = [self.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:12.0f];
}

- (void)showFloatingLabel
{
    CGRect currentFrame = self.floatingLabel.frame;

    self.floatingLabel.frame = CGRectMake(currentFrame.origin.x, self.bounds.size.height / 2.0f,
                                          currentFrame.size.width, currentFrame.size.height);

    [UIView animateWithDuration:0.45 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.floatingLabel.alpha = 1.0f;
        self.floatingLabel.frame = currentFrame;
    } completion:nil];
}

- (void)hideFloatingLabel
{
    self.floatingLabel.alpha = 0.0f;
}

- (void)updateFloatingLabelText
{
    self.floatingLabel.text = self.placeholder;
    [self.floatingLabel sizeToFit];
    [self overlayFloatingLabelOnTextField];
}

- (void)overlayFloatingLabelOnTextField
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat originX = textRect.origin.x;

    switch (self.textAlignment) {
        case NSTextAlignmentCenter:
            originX += (textRect.size.width / 2.0f) - (self.floatingLabel.bounds.size.width / 2.0f);
            break;
        case NSTextAlignmentRight:
            originX += textRect.size.width - self.floatingLabel.bounds.size.width;
            break;
        default:
            break;
    }
    self.floatingLabel.frame = CGRectMake(originX, self.padding.height,
                                          self.floatingLabel.frame.size.width, self.floatingLabel.frame.size.height);
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    CGRect newRect = CGRectMake(rect.origin.x + self.padding.width, rect.origin.y,
                                rect.size.width - (2 * self.padding.width), rect.size.height);

    if (!self.floatingLabelEnabled) {
        return newRect;
    }

    if (![self isEmpty]) {
        CGFloat dTop = self.floatingLabel.font.lineHeight + self.floatingLabelBottomMargin;
        newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsetsMake(dTop, 0.0, 0.0, 0.0));
    }
    return newRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

#pragma mark - Helpers

- (BOOL)isEmpty
{
    return (self.text.length == 0);
}

@end
