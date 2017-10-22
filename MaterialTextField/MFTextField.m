//
//  MFTextField.m
//  MaterialTextField
//
//  Created by Steph Sharp on 21/07/2015.
//  Copyright (c) 2015 Stephanie Sharp. All rights reserved.
//

#import "MFTextField.h"
#import "UIColor+MaterialTextField.h"
#import "UITextField+MFClearButton.h"
#import "UIFont+MaterialTextField.h"

static CGFloat const MFDefaultLabelFontSize = 13.0f;
static NSTimeInterval const MFDefaultAnimationDuration = 0.3;

@interface MFTextField ()

@property (nonatomic) CGRect textRect;
@property (nonatomic) CALayer *underlineLayer;
@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic) UILabel *placeholderLabel;
@property (nonatomic) NSLayoutConstraint *placeholderLabelTopConstraint;
@property (nonatomic) NSAttributedString *placeholderAttributedString;
@property (nonatomic) UIFont *defaultPlaceholderFont;
@property (nonatomic, readonly) BOOL shouldShowPlaceholder;
@property (nonatomic, readonly) BOOL placeholderIsHidden;
@property (nonatomic) BOOL placeholderIsAnimating;

@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) NSLayoutConstraint *errorLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorLabelHeightConstraint;
@property (nonatomic, readonly) BOOL hasError;
@property (nonatomic) BOOL errorIsAnimating;

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

    self.animatesPlaceholder = YES;
    self.placeholderColor = [UIColor mf_darkGrayColor];
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
    [self updatePlaceholderText];
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
    self.placeholderAttributedString = self.attributedPlaceholder;
    [self updatePlaceholderText];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    if (self.defaultPlaceholderColor) {
        attributedPlaceholder = [self attributedString:attributedPlaceholder withColor:self.defaultPlaceholderColor];
    }

    [super setAttributedPlaceholder:attributedPlaceholder];
    self.placeholderAttributedString = self.attributedPlaceholder;
    [self updatePlaceholderText];
    [self updateDefaultPlaceholderFont];
}

- (CGRect)textRect
{
    _textRect = [self textRectForBounds:self.bounds];
    return _textRect;
}

#pragma mark Placeholder

- (void)setAnimatesPlaceholder:(BOOL)animatesPlaceholder
{
    _animatesPlaceholder = animatesPlaceholder;
    [self removePlaceholderLabel];

    if (animatesPlaceholder) {
        [self setupPlaceholderLabel];
    }
}

- (void)setDefaultPlaceholderColor:(UIColor *)defaultPlaceholderColor
{
    _defaultPlaceholderColor = defaultPlaceholderColor ?: [UIColor mf_defaultPlaceholderGray];

    if (self.attributedPlaceholder.length > 0) {
        self.attributedPlaceholder = [self attributedString:self.attributedPlaceholder withColor:self.defaultPlaceholderColor];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self updatePlaceholderColor];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont ?: self.defaultPlaceholderFont;
    self.placeholderLabel.font = _placeholderFont;
    [self updatePlaceholderText];
}

- (UIFont *)defaultPlaceholderFont
{
    if (!_defaultPlaceholderFont) {
        _defaultPlaceholderFont = [self defaultFontForPlaceholder];
    }
    return _defaultPlaceholderFont;
}

#pragma mark Error

- (void)setError:(NSError *)error animated:(BOOL)animated
{
    _error = error;
    [self layoutErrorLabelAnimated:animated];
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

- (BOOL)shouldShowPlaceholder
{
    BOOL isEmpty = self.text.length == 0;

    return !isEmpty || (self.placeholderAnimatesOnFocus && self.isFirstResponder);
}

- (BOOL)hasError
{
    return self.error.localizedDescription.length > 0;
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
    [self mf_tintClearButton];

    if (self.animatesPlaceholder) {
        [self layoutPlaceholderLabelAnimated:YES];
    }
}

- (void)layoutUnderlineLayer
{
    [self updateUnderlineColor];
    [self updateUnderlineFrame];
}

- (void)layoutPlaceholderLabelAnimated:(BOOL)animated
{
    if (self.shouldShowPlaceholder) {
        [self updatePlaceholderColor];

        if (self.placeholderIsHidden) {
            [self showPlaceholderLabelAnimated:animated];
        }
    }
    else if (!self.placeholderIsHidden) {
        [self hidePlaceholderLabelAnimated:animated];
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
    CGFloat underlineHeight = self.isFirstResponder ? self.underlineEditingHeight : self.underlineHeight;
    CGFloat yPos = CGRectGetMaxY(self.textRect) + self.textPadding.height - underlineHeight;

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
    else if (self.placeholderAttributedString.length > 0) {
        font = [self.placeholderAttributedString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
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
    BOOL isUsingDefaultFont = [self.placeholderFont isEqual:self.defaultPlaceholderFont];

    self.defaultPlaceholderFont = [self defaultFontForPlaceholder];

    if (!self.defaultPlaceholderFont || isUsingDefaultFont) {
        self.placeholderFont = self.defaultPlaceholderFont;
    }
}

- (void)showPlaceholderLabelAnimated:(BOOL)animated
{
    if (self.placeholderAnimatesOnFocus) {
        // Call setPlaceholder on super so placeholderAttributedString is not set to nil
        [super setPlaceholder:nil];
    }

    if (animated && !self.placeholderIsAnimating) {
        [self.superview layoutIfNeeded];

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
                             // Layout label without animation if state has changed since animation started.
                             if (!self.shouldShowPlaceholder) {
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
    CGFloat finalDistanceFromTop = CGRectGetMinY(self.textRect) / 2.0f;

    if (self.placeholderAnimatesOnFocus) {
        self.attributedPlaceholder = self.placeholderAttributedString;
    }

    if (animated && !self.placeholderIsAnimating) {
        [self.superview layoutIfNeeded];

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
                             // Layout label without animation if state has changed since animation started.
                             if (self.shouldShowPlaceholder) {
                                 [self showPlaceholderLabelAnimated:NO];
                             }
                         }];
    }
    else if (!animated) {
        self.placeholderLabel.alpha = 0.0f;
        self.placeholderLabelTopConstraint.constant = finalDistanceFromTop;
    }
}

- (void)updatePlaceholderText
{
    self.placeholderLabel.text = self.placeholder ?: self.placeholderAttributedString.string;
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

- (NSAttributedString *)attributedString:(NSAttributedString *)attributedString withColor:(UIColor *)color
{
    NSMutableDictionary *attributes;

    if (attributedString.length > 0) {
        attributes = [[attributedString attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
    }
    else {
        attributes = [NSMutableDictionary dictionary];
    }
    attributes[NSForegroundColorAttributeName] = color;

    return [[NSAttributedString alloc] initWithString:attributedString.string attributes:attributes];
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
        [self.superview layoutIfNeeded];

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
                             [self.superview layoutIfNeeded];

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
    self.errorLabel.text = self.error.localizedDescription;
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
    rect.origin.y = [self adjustedYPositionForTextRect];
    self.textRect = rect;
    return rect;
}

- (CGFloat)adjustedYPositionForTextRect
{
    CGFloat top = ceil(self.textPadding.height);
    if (self.animatesPlaceholder) {
        top += self.placeholderFont.lineHeight;
    }
    return top;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect clearButtonRect = [super clearButtonRectForBounds:bounds];
    clearButtonRect.origin.y = CGRectGetMidY(_textRect) - (clearButtonRect.size.height / 2.0f);

    return clearButtonRect;
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

    self.animatesPlaceholder = NO;
    [self.errorLabel removeFromSuperview];
}

@end
