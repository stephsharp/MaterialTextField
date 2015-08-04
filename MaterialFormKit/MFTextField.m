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
static NSTimeInterval const MFDefaultAnimationDuration = 0.3;

@interface MFTextField ()

@property (nonatomic) UILabel *placeholderLabel;
@property (nonatomic) CALayer *underlineLayer;
@property (nonatomic) UILabel *errorLabel;

@property (nonatomic) NSLayoutConstraint *placeholderLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorLabelHeightConstraint;

@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL hasError;
@property (nonatomic, readonly) BOOL placeholderIsHidden;
@property (nonatomic) BOOL placeholderIsAnimating;
@property (nonatomic) BOOL errorIsAnimating;

@property (nonatomic) UIFont *defaultPlaceholderFont;

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
    [self setupUnderline];
    [self setupErrorLabel];
}

#pragma mark - Setup

- (void)setDefaults
{
    self.textPadding = CGSizeMake(0.0f, 8.0f);
    self.errorPadding = 4.0f;

    self.shouldAnimatePlaceholder = YES;
    self.placeholderColor = [UIColor mf_darkGrayColor];
    //self.placeholderDisabledColor = [UIColor mf_midGrayColor];
    self.placeholderFont = self.defaultPlaceholderFont;

    self.underlineHeight = 1.0f;
    self.underlineColor = [UIColor mf_lightGrayColor];
    self.underlineEditingHeight = 1.75f;

    self.errorColor = [UIColor mf_redColor];
    self.errorFont = [self defaultErrorFont];
}

- (void)setupTextField
{
    self.borderStyle = UITextBorderStyleNone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.clipsToBounds = NO;
}

- (void)setupUnderline
{
    self.underlineLayer = [CALayer layer];
    [self layoutUnderlineLayer];
    [self.layer addSublayer:self.underlineLayer];
}

- (void)setupPlaceholderLabel
{
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderLabel.font = self.placeholderFont;
    self.placeholderLabel.textAlignment = self.textAlignment;
    [self updatePlaceholderText:self.placeholder];
    [self updatePlaceholderColor];
    [self addSubview:self.placeholderLabel];
    [self setupPlaceholderConstraints];
    [self layoutPlaceholderLabelAnimated:NO];
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
    [self updateErrorLabelText];
    [self addSubview:self.errorLabel];
    [self setupErrorConstraints];
    [self layoutErrorLabelAnimated:NO];
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
        NSDictionary *metrics = @{@"topPadding": @([self topPaddingForErrorLabelHidden:!self.hasError])};

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

        self.errorLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.errorLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:0];
        [self.errorLabel addConstraint:self.errorLabelHeightConstraint];
        self.errorLabelHeightConstraint.active = !self.hasError;
    }
}

#pragma mark - Properties

#pragma mark UITextField

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateDefaultPlaceholderFont];
    [self updateErrorLabelPosition];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self updateDefaultPlaceholderFont];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    [self updatePlaceholderText:placeholder];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    [super setAttributedPlaceholder:attributedPlaceholder];
    [self updatePlaceholderText:attributedPlaceholder.string];
    [self updateDefaultPlaceholderFont];
}

#pragma mark Placeholder

- (void)setShouldAnimatePlaceholder:(BOOL)shouldAnimatePlaceholder
{
    _shouldAnimatePlaceholder = shouldAnimatePlaceholder;
    [self removePlaceholderLabel];

    if (shouldAnimatePlaceholder) {
        [self setupPlaceholderLabel];
    }
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont ? placeholderFont : self.defaultPlaceholderFont;
    self.placeholderLabel.font = _placeholderFont;
    [self updatePlaceholderText:self.placeholder];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self updatePlaceholderColor];
}

- (UIFont *)defaultPlaceholderFont
{
    if (!_defaultPlaceholderFont) {
        _defaultPlaceholderFont = [self defaultFontForPlaceholder];
    }
    return _defaultPlaceholderFont;
}

#pragma mark Error

- (void)setError:(NSString *)error
{
    _error = error;
    [self layoutErrorLabelAnimated:YES];
}

- (void)setErrorColor:(UIColor *)errorColor
{
    _errorColor = errorColor;
    self.errorLabel.textColor = errorColor;
}

- (void)setErrorFont:(UIFont *)errorFont
{
    _errorFont = errorFont;
    self.errorLabel.font = errorFont;
}

#pragma mark Computed

- (BOOL)isEmpty
{
    return self.text.length == 0;
}

- (BOOL)hasError
{
    return self.error.length > 0;
}

- (BOOL)placeholderIsHidden
{
    return self.placeholderLabel.alpha == 0.0f;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self layoutUnderlineLayer];

    if (self.shouldAnimatePlaceholder) {
        [self layoutPlaceholderLabelAnimated:YES];
    }

    [self layoutErrorLabelAnimated:YES];
}

- (void)layoutUnderlineLayer
{
    [self updateUnderlineColor];
    [self updateUnderlineFrame];
}

- (void)layoutPlaceholderLabelAnimated:(BOOL)animated
{
    if (self.isEmpty && !self.placeholderIsHidden) {
        [self hidePlaceholderLabelAnimated:animated];
    }
    else if (!self.isEmpty) {
        [self updatePlaceholderColor];

        if (self.placeholderIsHidden) {
            [self showPlaceholderLabelAnimated:animated];
        }
    }
}

- (void)layoutErrorLabelAnimated:(BOOL)animated
{
    if (self.hasError) {
        [self showErrorLabelAnimated:animated];
    }
    else {
        [self hideErrorLabelAnimated:animated];
    }
}

#pragma mark - Underline

- (void)updateUnderlineColor
{
    UIColor *underlineColor;

    if (self.hasError) {
        underlineColor = self.errorColor;
    }
    else {
        underlineColor = self.isFirstResponder ? self.tintColor : self.underlineColor;
    }

    self.underlineLayer.backgroundColor = underlineColor.CGColor;
}

- (void)updateUnderlineFrame
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat underlineHeight = self.isFirstResponder ? self.underlineEditingHeight : self.underlineHeight;
    CGFloat yPos = CGRectGetMaxY(textRect) + self.textPadding.height - underlineHeight;

    self.underlineLayer.frame = CGRectMake(0, yPos, CGRectGetWidth(self.bounds), underlineHeight);

    if (!self.errorIsAnimating) {
        [self updateErrorLabelPosition];
    }
}

#pragma mark - Placeholder

- (UIFont *)defaultFontForPlaceholder
{
    UIFont *font;

    if (self.attributedPlaceholder.length > 0) {
        font = [self.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    else if (self.attributedText.length > 0) {
        font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    else {
        font = self.font;
    }

    return [UIFont fontWithName:font.fontName size:MFDefaultLabelFontSize];
}

- (void)updateDefaultPlaceholderFont
{
    BOOL isUsingDefaultFont = [self font:self.placeholderFont isEqualToFont:self.defaultPlaceholderFont];

    self.defaultPlaceholderFont = [self defaultFontForPlaceholder];

    if (!self.defaultPlaceholderFont || isUsingDefaultFont) {
        self.placeholderFont = self.defaultPlaceholderFont;
    }
}

- (BOOL)font:(UIFont *)font1 isEqualToFont:(UIFont *)font2
{
    return [[[font1 fontDescriptor] fontAttributes] isEqual:[[font2 fontDescriptor] fontAttributes]];
}

- (void)showPlaceholderLabelAnimated:(BOOL)animated
{
    if (animated && !self.placeholderIsAnimating) {
        self.placeholderIsAnimating = YES;
        self.placeholderLabelTopConstraint.constant = 0;

        [UIView animateWithDuration:MFDefaultAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.placeholderLabel.alpha = 1.0f;
                             [self.superview layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.placeholderIsAnimating = NO;
                             // Layout label without animation if isEmpty has changed since animation started.
                             if (self.isEmpty) {
                                 [self hidePlaceholderLabelAnimated:NO];
                             }
                         }];
    }
    else if (!animated) {
        self.placeholderLabel.alpha = 1.0f;
        self.placeholderLabelTopConstraint.constant = 0;
    }
}

- (void)hidePlaceholderLabelAnimated:(BOOL)animated
{
    CGFloat finalDistanceFromTop = CGRectGetMinY([self textRectForBounds:self.bounds]) / 2.0f;

    if (animated && !self.placeholderIsAnimating) {
        self.placeholderIsAnimating = YES;
        self.placeholderLabelTopConstraint.constant = finalDistanceFromTop;

        [UIView animateWithDuration:MFDefaultAnimationDuration * 0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.placeholderLabel.alpha = 0.0f;
                             [self.superview layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.placeholderIsAnimating = NO;
                             // Layout label without animation if isEmpty has changed since animation started.
                             if (!self.isEmpty) {
                                 [self showPlaceholderLabelAnimated:NO];
                             }
                         }];
    }
    else if (!animated) {
        self.placeholderLabel.alpha = 0.0f;
        self.placeholderLabelTopConstraint.constant = finalDistanceFromTop;
    }
}

- (void)updatePlaceholderText:(NSString *)placeholder
{
    self.placeholderLabel.text = placeholder;
    [self.placeholderLabel sizeToFit];
    [self invalidateIntrinsicContentSize];
}

- (void)updatePlaceholderColor
{
    UIColor *color;

    if (self.isFirstResponder) {
        color = (self.hasError) ? self.errorColor : self.tintColor;
    }
    else {
        color = self.placeholderColor;
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

- (UIFont *)defaultErrorFont
{
    return [self.font fontWithSize:MFDefaultLabelFontSize];
}

- (void)showErrorLabelAnimated:(BOOL)animated
{
    [self updateErrorLabelText];

    if (animated && !self.errorIsAnimating) {
        self.errorIsAnimating = YES;
        self.errorLabelHeightConstraint.active = NO;
        self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabelHidden:NO];

        [UIView animateWithDuration:MFDefaultAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.superview layoutIfNeeded];
                             self.errorLabel.alpha = 1.0f;
                         } completion:^(BOOL finished) {
                              self.errorIsAnimating = NO;
                              // Layout error label without animation if isValid has changed since animation started.
                              if (!self.hasError) {
                                  [self hideErrorLabelAnimated:NO];
                              }
                         }];
    }
    else if (!animated) {
        self.errorLabel.alpha = 1.0f;
        self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabelHidden:NO];
        self.errorLabelHeightConstraint.active = NO;
    }
}

- (void)hideErrorLabelAnimated:(BOOL)animated
{
    if (animated && !self.errorIsAnimating) {
        self.errorIsAnimating = YES;
        [UIView animateWithDuration:MFDefaultAnimationDuration * 0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                            self.errorLabel.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabelHidden:YES];
                             self.errorLabelHeightConstraint.active = YES;

                             [UIView animateWithDuration:MFDefaultAnimationDuration * 0.3
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                    [self.superview layoutIfNeeded];
                                              } completion:^(BOOL finished) {
                                                  self.errorIsAnimating = NO;
                                                  [self updateErrorLabelText];
                                                  // Layout error label without animation if isValid has changed since animation started.
                                                  if (self.hasError) {
                                                      [self showErrorLabelAnimated:NO];
                                                  }
                                              }];
                         }];
    }
    else if (!animated) {
        self.errorLabel.alpha = 0.0f;
        self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabelHidden:YES];
        self.errorLabelHeightConstraint.active = YES;
    }

}

- (void)updateErrorLabelText
{
    self.errorLabel.text = self.error;
    [self.errorLabel sizeToFit];
}

- (CGFloat)topPaddingForErrorLabelHidden:(BOOL)hidden
{
    CGFloat topPadding = CGRectGetMaxY(self.underlineLayer.frame);

    if (!hidden) {
        topPadding += self.errorPadding;
    }

    return topPadding;
}

- (void)updateErrorLabelPosition
{
    self.errorLabelTopConstraint.constant = [self topPaddingForErrorLabelHidden:!self.hasError];
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

    CGFloat top = ceil(self.textPadding.height);
    if (self.shouldAnimatePlaceholder) {
        top += self.placeholderFont.lineHeight;
    }
    rect.origin.y = top;

    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

# pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicSize = [super intrinsicContentSize];

    if (!self.hasError) {
        intrinsicSize.height = CGRectGetMaxY(self.underlineLayer.frame);
    }

    return intrinsicSize;
}

#pragma mark - Interface builder

- (void)prepareForInterfaceBuilder
{
    [self setDefaults];
    [self setupTextField];
    [self setupUnderline];

    self.shouldAnimatePlaceholder = NO;
}

@end
