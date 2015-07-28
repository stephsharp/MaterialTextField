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

@property (nonatomic) UILabel *placeholderLabel;
@property (nonatomic) CALayer *bottomBorderLayer;
@property (nonatomic) UILabel *errorLabel;

@property (nonatomic) NSLayoutConstraint *placeholderTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorTopConstraint;

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

    //if (self.floatingPlaceholderEnabled) {
        [self setupFloatingLabel];
    //}

    //if (self.errorsEnabled) {
        [self setupErrorLabel];
    //}

    self.borderStyle = UITextBorderStyleNone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;

    [self setupConstraints];
}

#pragma mark - Setup

- (void)setDefaults
{
    self.labelPadding = CGSizeMake(0.0f, 8.0f);
    self.bottomPadding = 4.0f;

    self.floatingPlaceholderEnabled = YES;
    self.floatingPlaceholderColor = [UIColor mf_darkGrayColor];
    self.floatingPlaceholderDisabledColor = [UIColor mf_midGrayColor];
    self.floatingPlaceholderFont = [self defaultPlaceholderFont];

    self.bottomBorderHeight = 1.0f;
    self.bottomBorderColor = [UIColor mf_lightGrayColor];
    self.bottomBorderEditingHeight = 1.75f;

    // TODO: need to update constraints if errors are enabled/disabled
    self.errorsEnabled = YES;
    self.errorColor = [UIColor mf_redColor];
    self.errorMessage = @"Error";
    self.errorFont = [self defaultErrorFont];
    self.isValid = YES;
}

- (void)setupBottomBorder
{
    CGRect textRect = [self textRectForBounds:self.bounds];

    self.bottomBorderLayer = [CALayer layer];
    self.bottomBorderLayer.frame = CGRectMake(0, CGRectGetMaxY(textRect) + self.labelPadding.height - 1,
                                              CGRectGetWidth(self.bounds), 1);
    self.bottomBorderLayer.backgroundColor = self.bottomBorderColor.CGColor;
    [self.layer addSublayer:self.bottomBorderLayer];
}

- (void)setupFloatingLabel
{
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderLabel.font = self.floatingPlaceholderFont;
    self.placeholderLabel.alpha = 0.0f;
    [self updateFloatingLabelText];
    [self addSubview:self.placeholderLabel];
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
    self.errorLabel.alpha = 0.0f;
    [self updateErrorLabelText];
    [self addSubview:self.errorLabel];
}

- (void)setupConstraints
{
    CGFloat vPadding3 = self.placeholderLabel.font.lineHeight + self.font.lineHeight + (self.labelPadding.height * 2) + self.bottomPadding;
    // not working...
    if (!self.floatingPlaceholderEnabled) {
        vPadding3 = self.font.lineHeight + (self.labelPadding.height * 2) + self.bottomPadding;
    }

    NSDictionary *views = @{@"placeholder": self.placeholderLabel, @"error": self.errorLabel};
    NSDictionary *metrics = @{@"vPadding": @(self.labelPadding.height),
                              @"vPadding3": @(vPadding3),
                              @"hPadding": @(self.labelPadding.width),
                              @"errorPadding": @(self.bottomPadding)};

    if (self.errorsEnabled) {
        NSArray *verticalErrorConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vPadding3-[error]-(>=0,0@900)-|"
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:views];
        [self addConstraints:verticalErrorConstraints];
        self.errorTopConstraint = verticalErrorConstraints[0];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[error]->=0-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    }

    if (self.floatingPlaceholderEnabled) {
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[placeholder]"
                                                                               options:0
                                                                               metrics:metrics
                                                                                 views:views];

        [self addConstraints:verticalConstraints];
        self.placeholderTopConstraint = verticalConstraints[0];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[placeholder]|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    }
}

#pragma mark - Properties

- (void)setFloatingPlaceholderFont:(UIFont *)floatingPlaceholderFont
{
    _floatingPlaceholderFont = floatingPlaceholderFont;
    self.placeholderLabel.font = floatingPlaceholderFont;
}

- (void)setErrorFont:(UIFont *)errorFont
{
    _errorFont = errorFont;
    self.errorLabel.font = errorFont;
}

- (void)setFloatingPlaceholderColor:(UIColor *)floatingPlaceholderColor
{
    _floatingPlaceholderColor = floatingPlaceholderColor;
    self.placeholderLabel.textColor = floatingPlaceholderColor;
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

- (void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
    [self updateErrorLabelText];
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
        if (!self.isFirstResponder) {
            self.placeholderLabel.textColor = self.floatingPlaceholderColor;
        }
        else if (self.isValid) {
            self.placeholderLabel.textColor = self.tintColor;
        }
        else if (self.errorsEnabled) {
            self.placeholderLabel.textColor = self.errorColor;
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
    if (self.isValid) {
        self.bottomBorderLayer.backgroundColor = self.isFirstResponder ? self.tintColor.CGColor : self.bottomBorderColor.CGColor;
    }
    else if (self.errorsEnabled) {
        self.bottomBorderLayer.backgroundColor = self.errorColor.CGColor;
    }
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat borderHeight = self.isFirstResponder ? self.bottomBorderEditingHeight : self.bottomBorderHeight;
    self.bottomBorderLayer.frame = CGRectMake(0, CGRectGetMaxY(textRect) + self.labelPadding.height - borderHeight,
                                              CGRectGetWidth(self.bounds), borderHeight);
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

- (BOOL)isValid
{
    return self.text.length < 2;
}

#pragma mark - Floating placeholder label

- (UIFont *)defaultPlaceholderFont
{
    UIFontDescriptor * fontDescriptor = [self.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontDescriptor size:MFDefaultLabelFontSize];
}

- (UIFont *)defaultErrorFont
{
    return [self.font fontWithSize:MFDefaultLabelFontSize];
}

- (void)showFloatingLabel
{
    CGFloat finalDistanceFromTop = self.placeholderTopConstraint.constant;

    self.placeholderTopConstraint.constant = CGRectGetMinY([self textRectForBounds:self.bounds]) / 2.0f;
    [self layoutIfNeeded];

    self.placeholderTopConstraint.constant = finalDistanceFromTop;
    [UIView animateWithDuration:MFFloatingLabelAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.placeholderLabel.alpha = 1.0f;
                         [self layoutIfNeeded];
                     } completion:nil];
}

- (void)hideFloatingLabel
{
    self.placeholderLabel.alpha = 0.0f;
}

- (BOOL)floatingLabelIsHidden
{
    return (self.placeholderLabel.alpha == 0.0f);
}

- (void)updateFloatingLabelText
{
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textAlignment = self.textAlignment;
    [self.placeholderLabel sizeToFit];
}

#pragma mark - Error message label

- (void)showErrorLabel
{
    CGFloat finalDistanceFromTop = self.errorTopConstraint.constant;

    self.errorTopConstraint.constant = CGRectGetMaxY(self.bottomBorderLayer.frame);
    [self layoutIfNeeded];

    self.errorTopConstraint.constant = finalDistanceFromTop;
    [UIView animateWithDuration:MFFloatingLabelAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.errorLabel.alpha = 1.0f;
                         [self layoutIfNeeded];
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

- (void)updateErrorLabelText
{
    self.errorLabel.text = self.errorMessage;
    [self.errorLabel sizeToFit];
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
//    if (self.floatingPlaceholderEnabled) {
        CGRect rect = [super textRectForBounds:bounds];
        rect.size.height = self.font.lineHeight;

        CGFloat top = self.placeholderLabel.font.lineHeight + ceil(self.labelPadding.height);
        rect.origin.y = top;
//    }

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

- (void)prepareForInterfaceBuilder
{
    if (self.floatingPlaceholderEnabled) {
        self.placeholderLabel.alpha = 1.0f;
    }

    if (self.errorsEnabled) {
        self.isValid = NO;
        self.errorLabel.alpha = 1.0f;
    }
    
    [self sharedInit];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.errorTopConstraint.constant = self.placeholderLabel.font.lineHeight + self.font.lineHeight + (self.labelPadding.height * 2) + self.bottomPadding;
}

@end
