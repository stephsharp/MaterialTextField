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
static NSTimeInterval const MFPlaceholderAnimationDuration = 0.45;

@interface MFTextField ()

@property (nonatomic) UILabel *placeholderLabel;
@property (nonatomic) CALayer *bottomBorderLayer;
@property (nonatomic) UILabel *errorLabel;

@property (nonatomic) NSLayoutConstraint *placeholderLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorLabelTopConstraint;

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
    [self setupTextField];
    [self setupBottomBorder];

    if (self.floatingPlaceholderEnabled) {
        [self setupPlaceholderLabel];
    }

    if (self.errorsEnabled) {
        [self setupErrorLabel];
    }
}

#pragma mark - Setup

- (void)setDefaults
{
    self.labelPadding = CGSizeMake(0.0f, 8.0f);
    self.errorPadding = 4.0f;

    self.floatingPlaceholderEnabled = YES;
    self.floatingPlaceholderColor = [UIColor mf_darkGrayColor];
    self.floatingPlaceholderDisabledColor = [UIColor mf_midGrayColor];
    self.floatingPlaceholderFont = [self defaultPlaceholderFont];

    self.bottomBorderHeight = 1.0f;
    self.bottomBorderColor = [UIColor mf_lightGrayColor];
    self.bottomBorderEditingHeight = 1.75f;

    self.errorsEnabled = NO;
    self.errorColor = [UIColor mf_redColor];
    self.errorMessage = @"Error";
    self.errorFont = [self defaultErrorFont];
    self.isValid = YES;
}

- (void)setupTextField
{
    self.borderStyle = UITextBorderStyleNone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
}

- (void)setupBottomBorder
{
    self.bottomBorderLayer = [CALayer layer];
    [self layoutBottomBorderLayer];
    [self.layer addSublayer:self.bottomBorderLayer];
}

- (void)setupPlaceholderLabel
{
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderLabel.font = self.floatingPlaceholderFont;
    self.placeholderLabel.textAlignment = self.textAlignment;
    [self hidePlaceholderLabel];
    [self updatePlaceholderText];
    [self updatePlaceholderColor];
    [self addSubview:self.placeholderLabel];
    [self setupPlaceholderConstraints];
}

- (void)setupErrorLabel
{
    self.errorLabel = [UILabel new];
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.errorLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.errorLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    self.errorLabel.font = self.errorFont;
    self.errorLabel.textAlignment = NSTextAlignmentLeft;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.textColor = self.errorColor;
    [self hideErrorLabel];
    [self updateErrorLabelText];
    [self addSubview:self.errorLabel];
    [self setupErrorConstraints];
}

- (void)setupPlaceholderConstraints
{
    if (self.placeholderLabel) {
        NSDictionary *views = @{@"placeholder": self.placeholderLabel};

        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[placeholder]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views];
        self.placeholderLabelTopConstraint = verticalConstraints[0];
        [self addConstraints:verticalConstraints];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[placeholder]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
    }
}

- (void)setupErrorConstraints
{
    if (self.errorLabel) {
        NSDictionary *views = @{@"error": self.errorLabel};
        NSDictionary *metrics = @{@"topPadding": @([self topPaddingForErrorLabel])};

        NSString *visualFormatString = @"V:|-topPadding-[error]-(>=0,0@900)-|";
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatString
                                                                               options:0
                                                                               metrics:metrics
                                                                                 views:views];
        self.errorLabelTopConstraint = verticalConstraints[0];
        [self addConstraints:verticalConstraints];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[error]->=0-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    }
}

#pragma mark - Properties

- (void)setFloatingPlaceholderEnabled:(BOOL)floatingPlaceholderEnabled
{
    _floatingPlaceholderEnabled = floatingPlaceholderEnabled;
    [self removePlaceholderLabel];

    if (floatingPlaceholderEnabled) {
        [self setupPlaceholderLabel];
    }
}

- (void)setFloatingPlaceholderFont:(UIFont *)floatingPlaceholderFont
{
    _floatingPlaceholderFont = floatingPlaceholderFont;
    self.placeholderLabel.font = floatingPlaceholderFont;
}

- (void)setFloatingPlaceholderColor:(UIColor *)floatingPlaceholderColor
{
    _floatingPlaceholderColor = floatingPlaceholderColor;
    [self updatePlaceholderColor];
}

- (void)setErrorsEnabled:(BOOL)errorsEnabled
{
    _errorsEnabled = errorsEnabled;
    [self removeErrorLabel];

    if (errorsEnabled) {
        [self setupErrorLabel];
    }
}

- (void)setErrorFont:(UIFont *)errorFont
{
    _errorFont = errorFont;
    self.errorLabel.font = errorFont;
}

- (void)setErrorColor:(UIColor *)errorColor
{
    _errorColor = errorColor;
    self.errorLabel.textColor = errorColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self updatePlaceholderText];
}

- (void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
    [self updateErrorLabelText];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateErrorLabelPosition];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self layoutBottomBorderLayer];

    if (self.floatingPlaceholderEnabled) {
        [self layoutPlaceholderLabel];
    }

    if (self.errorsEnabled) {
        [self layoutErrorLabel];
    }
}

- (void)layoutBottomBorderLayer
{
    [self updateBottomBorderColor];
    [self updateBottomBorderFrame];
}

- (void)layoutPlaceholderLabel
{
    if ([self isEmpty]) {
        [self hidePlaceholderLabel];
    }
    else {
        [self updatePlaceholderColor];

        if ([self placeholderLabelIsHidden]) {
            [self showPlaceholderLabelAnimated:YES];
        }
    }
}

- (void)layoutErrorLabel
{
    if (self.isValid) {
        [self hideErrorLabel];
    }
    else {
        if ([self errorLabelIsHidden]) {
            [self showErrorLabelAnimated:YES];
        }
    }
}

#pragma mark - Bottom border

- (void)updateBottomBorderColor
{
    UIColor *borderColor;

    if (self.errorsEnabled && !self.isValid) {
        borderColor = self.errorColor;
    }
    else {
        borderColor = self.isFirstResponder ? self.tintColor : self.bottomBorderColor;
    }

    self.bottomBorderLayer.backgroundColor = borderColor.CGColor;
}

- (void)updateBottomBorderFrame
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat borderHeight = self.isFirstResponder ? self.bottomBorderEditingHeight : self.bottomBorderHeight;
    CGFloat yPos = CGRectGetMaxY(textRect) + self.labelPadding.height - borderHeight;

    self.bottomBorderLayer.frame = CGRectMake(0, yPos, CGRectGetWidth(self.bounds), borderHeight);
}

#pragma mark - Floating placeholder

- (UIFont *)defaultPlaceholderFont
{
    UIFontDescriptor * fontDescriptor = [self.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:MFDefaultLabelFontSize];
}

- (UIFont *)defaultErrorFont
{
    return [self.font fontWithSize:MFDefaultLabelFontSize];
}

- (void)showPlaceholderLabelAnimated:(BOOL)animated
{
    if (animated) {
        CGFloat finalDistanceFromTop = self.placeholderLabelTopConstraint.constant;

        self.placeholderLabelTopConstraint.constant = CGRectGetMinY([self textRectForBounds:self.bounds]) / 2.0f;
        [self layoutIfNeeded];

        self.placeholderLabelTopConstraint.constant = finalDistanceFromTop;
        [UIView animateWithDuration:MFPlaceholderAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.placeholderLabel.alpha = 1.0f;
                             [self layoutIfNeeded];
                         } completion:nil];
    }
    else {
        self.placeholderLabel.alpha = 1.0f;
    }
}

- (void)hidePlaceholderLabel
{
    self.placeholderLabel.alpha = 0.0f;
}

- (BOOL)placeholderLabelIsHidden
{
    return (self.placeholderLabel.alpha == 0.0f);
}

- (void)updatePlaceholderText
{
    self.placeholderLabel.text = self.placeholder;
    [self.placeholderLabel sizeToFit];
}

- (void)updatePlaceholderColor
{
    UIColor *color;

    if (self.isFirstResponder) {
        color = (self.errorsEnabled && !self.isValid) ? self.errorColor : self.tintColor;
    }
    else {
        color = self.floatingPlaceholderColor;
    }

    self.placeholderLabel.textColor = color;
}

- (void)removePlaceholderLabel
{
    if (self.placeholderLabel) {
        [self.placeholderLabel removeFromSuperview];
        self.placeholderLabel = nil;
    }
}

#pragma mark - Error message

- (void)showErrorLabelAnimated:(BOOL)animated
{
    if (animated) {
        CGFloat finalDistanceFromTop = self.errorLabelTopConstraint.constant;

        self.errorLabelTopConstraint.constant = CGRectGetMaxY(self.bottomBorderLayer.frame);
        [self layoutIfNeeded];

        self.errorLabelTopConstraint.constant = finalDistanceFromTop;
        [UIView animateWithDuration:MFPlaceholderAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.errorLabel.alpha = 1.0f;
                             [self layoutIfNeeded];
                         } completion:nil];
    }
    else {
        self.errorLabel.alpha = 1.0f;
    }
}

- (void)hideErrorLabel
{
    self.errorLabel.alpha = 0.0f;
}

- (BOOL)errorLabelIsHidden
{
    return (self.errorLabel.alpha == 0.0f);
}

- (void)updateErrorLabelText
{
    self.errorLabel.text = self.errorMessage;
    [self.errorLabel sizeToFit];
}

- (CGFloat)topPaddingForErrorLabel
{
    CGFloat topPadding = self.font.lineHeight + (self.labelPadding.height * 2) + self.errorPadding;

    if (self.floatingPlaceholderEnabled) {
        topPadding += self.placeholderLabel.font.lineHeight;
    }

    return topPadding;
}

- (void)updateErrorLabelPosition
{
    self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabel];
}

- (void)removeErrorLabel
{
    if (self.errorLabel) {
        [self.errorLabel removeFromSuperview];
        self.errorLabel = nil;
    }
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    rect.size.height = self.font.lineHeight;

    CGFloat top = ceil(self.labelPadding.height);
    if (self.floatingPlaceholderEnabled) {
        top += self.placeholderLabel.font.lineHeight;
    }
    rect.origin.y = top;

    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

//- (void)drawPlaceholderInRect:(CGRect)rect
//{
//    [super drawPlaceholderInRect:rect];
//}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (BOOL)isEmpty
{
    return (self.text.length == 0);
}

#pragma mark - Interface builder

- (void)prepareForInterfaceBuilder
{
    if (self.floatingPlaceholderEnabled) {
        [self showPlaceholderLabelAnimated:NO];
    }

    if (self.errorsEnabled) {
        self.isValid = NO;
        [self showErrorLabelAnimated:NO];
    }

    [self sharedInit];
}

@end
