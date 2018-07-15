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
@property (nonatomic) NSArray<NSLayoutConstraint *> *placeholderLabelHorizontalConstraints;
@property (nonatomic) NSAttributedString *placeholderAttributedString;
@property (nonatomic) UIFont *defaultPlaceholderFont;
@property (nonatomic, readonly) BOOL shouldShowPlaceholder;
@property (nonatomic, readonly) BOOL placeholderIsHidden;
@property (nonatomic) BOOL placeholderIsAnimating;

@property (nonatomic) UILabel *errorLabel;
@property (nonatomic) NSLayoutConstraint *errorLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *errorLabelZeroHeightConstraint;
@property (nonatomic) NSArray<NSLayoutConstraint *> *errorLabelHorizontalConstraints;

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
    self.errorPadding = CGSizeMake(0.0f, 4.0f);

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
    self.placeholderLabelTopConstraint = [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.topAnchor];
    
    NSLayoutConstraint *leading = [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                                                      constant:self.textPadding.width];
    NSLayoutConstraint *trailing = [self.trailingAnchor constraintEqualToAnchor:self.placeholderLabel.trailingAnchor
                                                                       constant:self.textPadding.width];
    self.placeholderLabelHorizontalConstraints = @[leading, trailing];

    [NSLayoutConstraint activateConstraints:@[self.placeholderLabelTopConstraint, leading, trailing]];
}

- (void)setupErrorConstraints
{
    self.errorLabelTopConstraint = [self.errorLabel.topAnchor constraintEqualToAnchor:self.topAnchor
                                                                             constant:[self topPaddingForErrorLabelHidden:!self.hasError]];
    NSLayoutConstraint *bottom = [self.errorLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor];
    NSLayoutConstraint *leading = [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                                                constant:self.errorPadding.width];
    NSLayoutConstraint *trailing = [self.trailingAnchor constraintGreaterThanOrEqualToAnchor:self.errorLabel.trailingAnchor
                                                                                    constant:self.errorPadding.width];
    self.errorLabelHorizontalConstraints = @[leading, trailing];
    
    [NSLayoutConstraint activateConstraints:@[self.errorLabelTopConstraint, bottom, leading, trailing]];
    
    self.errorLabelZeroHeightConstraint = [self.errorLabel.heightAnchor constraintEqualToConstant:0];
    self.errorLabelZeroHeightConstraint.active = !self.hasError;
}

#pragma mark - Properties
    
#pragma mark Padding
    
- (void)setTextPadding:(CGSize)textPadding
{
    _textPadding = textPadding;
    [self updatePlaceholderHorizontalConstraints];
}
    
- (void)updatePlaceholderHorizontalConstraints
{
    for (NSLayoutConstraint *constraint in self.placeholderLabelHorizontalConstraints) {
        constraint.constant = self.textPadding.width;
    }
}
    
- (void)setErrorPadding:(CGSize)errorPadding
{
    _errorPadding = errorPadding;
    [self updateErrorHorizontalConstraints];
}
    
- (void)updateErrorHorizontalConstraints
{
    for (NSLayoutConstraint *constraint in self.errorLabelHorizontalConstraints) {
        constraint.constant = self.errorPadding.width;
    }
}

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
        [self showPlaceholderLabelAnimated:animated];
    }
    else {
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
    
    if (!self.placeholderIsHidden) {
        return;
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
    if (self.placeholderIsHidden) {
        return;
    }

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

    return [[NSAttributedString alloc] initWithString:attributedString.string ?: @""
                                           attributes:attributes];
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
        self.errorLabelZeroHeightConstraint.active = NO;
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
        self.errorLabelZeroHeightConstraint.active = NO;
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
                             self.errorLabelZeroHeightConstraint.active = YES;

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
        self.errorLabelZeroHeightConstraint.active = YES;
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
        topPadding += self.errorPadding.height;
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
    CGRect superRect = [super textRectForBounds:bounds];
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    BOOL hasLeftView = [self leftViewRectForBounds:bounds].size.width > 0;
    BOOL hasRightView = [self rightViewRectForBounds:bounds].size.width > 0;
    
    CGFloat leftPadding = hasLeftView ? 0 : self.textPadding.width;
    CGFloat rightPadding = hasRightView ? rightRect.size.width : self.textPadding.width * 2;
    
    CGRect rect = CGRectMake(superRect.origin.x + leftPadding,
                             [self adjustedYPositionForTextRect],
                             superRect.size.width - rightPadding,
                             self.font.lineHeight);
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

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    rightViewRect.origin.x = rightViewRect.origin.x - self.textPadding.width;
    rightViewRect.origin.y = CGRectGetMidY(_textRect) - (rightViewRect.size.height / 2.0f);
    
    return rightViewRect;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftViewRect = [super leftViewRectForBounds:bounds];
    leftViewRect.origin.x = self.textPadding.width;
    leftViewRect.origin.y = CGRectGetMidY(_textRect) - (leftViewRect.size.height / 2.0f);
    
    return leftViewRect;
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
