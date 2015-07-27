//
//  MFTextField.m
//  MaterialFormKit
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "MFTextField.h"
#import "UIColor+MaterialFormKit.h"

static CGFloat const MFDefaultLabelFontSize = 13.0f;
static NSTimeInterval const MFFloatingLabelAnimationDuration = 0.45;

@interface MFTextField ()

@property (nonatomic) UILabel *floatingLabel;
@property (nonatomic) CALayer *bottomBorderLayer;
@property (nonatomic) UILabel *errorLabel;

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
    [self setupErrorLabel];

    self.borderStyle = UITextBorderStyleNone;
}

#pragma mark - Setup

- (void)setDefaults
{
    self.labelPadding = CGSizeMake(0.0f, 2.0f);
    self.bottomPadding = 0.0f;

    self.floatingPlaceholderEnabled = YES;
    self.floatingPlaceholderColor = [UIColor mf_darkGrayColor];
    self.floatingPlaceholderDisabledColor = [UIColor mf_midGrayColor];
    self.labelFont = [self defaultLabelFont];

    self.bottomBorderHeight = 1.0f;
    self.bottomBorderColor = [UIColor mf_lightGrayColor];
    self.bottomBorderEditingHeight = 1.75f;

    self.errorsEnabled = NO;
    self.errorColor = [UIColor mf_redColor];
    self.errorMessage = @"Error";
    self.isValid = YES;
}

- (void)setupBottomBorder
{
    self.bottomBorderLayer = [CALayer layer];
    self.bottomBorderLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 1,
                                              CGRectGetWidth(self.bounds), 1);
    self.bottomBorderLayer.backgroundColor = self.bottomBorderColor.CGColor;
    [self.layer addSublayer:self.bottomBorderLayer];
}

- (void)setupFloatingLabel
{
    self.floatingLabel = [UILabel new];
    self.floatingLabel.font = self.labelFont;
    self.floatingLabel.alpha = 0.0f;
    [self updateFloatingLabelText];
    [self addSubview:self.floatingLabel];
}

- (void)setupErrorLabel
{
    self.errorLabel = [UILabel new];
    self.errorLabel.font = self.labelFont;
    self.errorLabel.textColor = self.errorColor;
    self.errorLabel.alpha = 0.0f;
    [self updateErrorLabelText];
    [self addSubview:self.errorLabel];
}

#pragma mark - Properties

- (void)setLabelFont:(UIFont *)labelFont
{
    _labelFont = labelFont;
    self.floatingLabel.font = labelFont;
    self.errorLabel.font = labelFont;
}

- (void)setFloatingPlaceholderColor:(UIColor *)floatingPlaceholderColor
{
    _floatingPlaceholderColor = floatingPlaceholderColor;
    self.floatingLabel.textColor = floatingPlaceholderColor;
}

- (void)setErrorColor:(UIColor *)errorColor
{
    _errorColor = errorColor;
    self.errorLabel.textColor = errorColor;
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

    if (self.floatingPlaceholderEnabled) {
        [self layoutFloatingLabel];
    }

    [self layoutBottomBorderLayer];

    if (self.errorsEnabled) {
        [self layoutErrorLabel];
    }
}

- (void)layoutFloatingLabel
{
    if (![self isEmpty]) {
        if (self.isValid) {
            self.floatingLabel.textColor = self.isFirstResponder ? self.tintColor : self.floatingPlaceholderColor;
        }
        else if (self.errorsEnabled) {
            self.floatingLabel.textColor = self.errorColor;
        }

        if ([self floatingLabelIsHidden]) {
            [self showFloatingLabel];
        }
    }
    else {
        [self hideFloatingLabel];
    }
}

- (void)layoutBottomBorderLayer
{
    CGFloat borderHeight = self.isFirstResponder ? self.bottomBorderEditingHeight : self.bottomBorderHeight;
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.bounds) - borderHeight,
                              CGRectGetWidth(self.bounds), borderHeight);

    if (self.isValid) {
        self.bottomBorderLayer.backgroundColor = self.isFirstResponder ? self.tintColor.CGColor : self.bottomBorderColor.CGColor;
    }
    else if (self.errorsEnabled) {
        self.bottomBorderLayer.backgroundColor = self.errorColor.CGColor;
        frame.origin.y -= self.errorLabel.font.lineHeight + self.labelPadding.height;
    }

    self.bottomBorderLayer.frame = frame;
}

- (void)layoutErrorLabel
{
    if (!self.isValid) {
        if ([self errorLabelIsHidden]) {
            [self showErrorLabel];
        }
    }
    else {
        [self hideErrorLabel];
    }
}

#pragma mark - Floating placeholder label

- (UIFont *)defaultLabelFont
{
    UIFontDescriptor * fontDescriptor = [self.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:MFDefaultLabelFontSize];
}

- (void)showFloatingLabel
{
    CGRect currentFrame = self.floatingLabel.frame;

    self.floatingLabel.frame = CGRectMake(CGRectGetMinX(currentFrame),
                                          CGRectGetMaxY(self.bottomBorderLayer.frame) / 2.0f,
                                          currentFrame.size.width, currentFrame.size.height);

    [UIView animateWithDuration:MFFloatingLabelAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.floatingLabel.alpha = 1.0f;
                        self.floatingLabel.frame = currentFrame;
                     } completion:nil];
}

- (void)hideFloatingLabel
{
    self.floatingLabel.alpha = 0.0f;
}

- (BOOL)floatingLabelIsHidden
{
    return (self.floatingLabel.alpha == 0.0f);
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
            originX += (CGRectGetWidth(textRect) / 2.0f) - (CGRectGetWidth(self.floatingLabel.bounds) / 2.0f);
            break;
        case NSTextAlignmentRight:
            originX += CGRectGetWidth(textRect) - CGRectGetWidth(self.floatingLabel.bounds);
            break;
        default:
            break;
    }
    self.floatingLabel.frame = CGRectMake(originX, 0,
                                          CGRectGetWidth(self.floatingLabel.frame),
                                          CGRectGetHeight(self.floatingLabel.frame));
}

#pragma mark - Error message label

- (void)updateErrorLabelText
{
    self.errorLabel.text = self.errorMessage;
    [self.errorLabel sizeToFit];
    [self placeErrorLabelBelowTextField];
}

- (void)placeErrorLabelBelowTextField
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat originX = textRect.origin.x;

    switch (self.textAlignment) {
        case NSTextAlignmentCenter:
            originX += (CGRectGetWidth(textRect) / 2.0f) - (CGRectGetWidth(self.errorLabel.bounds) / 2.0f);
            break;
        case NSTextAlignmentRight:
            originX += CGRectGetWidth(textRect) - CGRectGetWidth(self.errorLabel.bounds);
            break;
        default:
            break;
    }
    CGFloat originY = CGRectGetHeight(self.bounds) - CGRectGetHeight(self.errorLabel.frame);
    self.errorLabel.frame = CGRectMake(originX, originY,
                                       CGRectGetWidth(self.errorLabel.frame),
                                       CGRectGetHeight(self.errorLabel.frame));
}

- (void)showErrorLabel
{
    CGRect currentFrame = self.errorLabel.frame;

    self.errorLabel.frame = CGRectMake(CGRectGetMinX(currentFrame), CGRectGetMaxY(self.bottomBorderLayer.frame),
                                       currentFrame.size.width, currentFrame.size.height);

    [UIView animateWithDuration:MFFloatingLabelAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.errorLabel.alpha = 1.0f;
                         self.errorLabel.frame = currentFrame;
                     } completion:nil];
}

- (void)hideErrorLabel
{
    self.errorLabel.alpha = 0.0f;
}

- (BOOL)errorLabelIsHidden
{
    return (self.errorLabel.alpha == 0.0f);
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    CGRect newRect = CGRectMake(rect.origin.x + self.labelPadding.width, rect.origin.y,
                                rect.size.width - (2 * self.labelPadding.width), rect.size.height);

//    if (!self.floatingPlaceholderEnabled) {
//        return newRect;
//    }
//
//    if (![self isEmpty]) {
//        CGFloat dTop = self.floatingLabel.font.lineHeight + self.bottomPadding;
//        newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsetsMake(dTop, 0.0, 0.0, 0.0));
//    }
    return newRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (BOOL)isEmpty
{
    return (self.text.length == 0);
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat width = CGRectGetWidth(self.floatingLabel.frame) + (2 * self.labelPadding.width);
    CGFloat height = CGRectGetHeight(self.floatingLabel.frame) + self.labelPadding.height + CGRectGetHeight(textRect) + self.bottomPadding + self.bottomBorderHeight + self.labelPadding.height + CGRectGetHeight(self.errorLabel.frame);

    return CGSizeMake(width, height);
}

@end
