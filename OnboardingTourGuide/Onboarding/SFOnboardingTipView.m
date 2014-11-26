//
//  SFOnboardingTipView.m
//  InsightsSDK
//
//  Created by Behzad Richey on 7/18/14.

/*  Copyright (c) 2014, Salesforce.com, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *  Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 *  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFOnboardingTipView.h"

static CGFloat const kOnboardingTipAlpha = 0.95;
static CGFloat const kOnboardingTipCorderRadius = 5.0;
static CGFloat const kOnboardingTipPaddingHorizontal = 6.0;
static CGFloat const kOnboardingTipPaddingVertical = 8.0;
static CGFloat const kOnboardingTipViewCloseButtonSize = 60.0;
static CGFloat const kOnboardingTipViewCloseButtonImageInset = 35.0;
static CGFloat const kOnboardingTipViewMaxWidth = 292.0;
static CGFloat const kOnboardingTipViewMaxHeight = 100.0;

@interface SFOnboardingTipView ()

@property (nonatomic) BOOL arrowLocationCustomized;
@property (nonatomic) CGFloat arrowLocation;

@property (nonatomic, strong) NSString *tip;
@property (nonatomic, strong, readwrite) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *backgroundView;

// We use a UITextView instead of a UILabel in order to be able to wrap the text around the "x" button.
@property (nonatomic, strong) UITextView *tipTextView;

@end

@implementation SFOnboardingTipView

- (id)initWithFrame:(CGRect)frame withArrowDirection:(SFOnboardingTipViewArrowDirection)arrowDirection {
    self = [self initWithFrame:frame];
    
    if (self) {
        self.arrowDirection = arrowDirection;
        self.backgroundColor = [UIColor clearColor];
        self.maximumSize = CGSizeZero;
        
        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        self.arrowView.alpha = kOnboardingTipAlpha;
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.alpha = kOnboardingTipAlpha;
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.173 green:0.239 blue:0.302 alpha:1.0];
        
        self.tipTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
        self.tipTextView.backgroundColor = [UIColor clearColor];
        self.tipTextView.editable = NO;
        self.tipTextView.font = [UIFont systemFontOfSize:14.0];
        self.tipTextView.scrollEnabled = NO;
        self.tipTextView.selectable = NO;
        self.tipTextView.textColor = [UIColor whiteColor];
        self.tipTextView.textContainerInset = UIEdgeInsetsZero;
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"close-tip"] forState:UIControlStateNormal];
        
        [self addSubview:self.arrowView];
        [self addSubview:self.backgroundView];
        [self.backgroundView addSubview:self.tipTextView];
        [self.backgroundView addSubview:self.closeButton];
        
        self.accessibilityIdentifier = @"onboarding.tooltip";
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize arrowViewSize = self.arrowView.image.size;
    CGRect arrowViewFrame = CGRectMake(0.0, CGRectGetHeight(self.bounds) - arrowViewSize.height, arrowViewSize.width, arrowViewSize.height);
    CGAffineTransform arrowViewTransform = CGAffineTransformIdentity;
    CGRect backgroundViewFrame = self.bounds;
    backgroundViewFrame.size.height -= arrowViewSize.height;
    
    if (self.arrowDirection == SFOnboardingTipViewArrowDirectionUp) {
        arrowViewFrame.origin.y = 0.0;
        arrowViewTransform = CGAffineTransformMakeRotation(M_PI);
        backgroundViewFrame.origin.y += arrowViewSize.height;
    }
    
    // Background View
    self.backgroundView.frame = backgroundViewFrame;
    self.backgroundView.layer.cornerRadius = kOnboardingTipCorderRadius;
    
    // Arrow View
    self.arrowView.frame = arrowViewFrame;
    self.arrowView.transform = arrowViewTransform;
    CGFloat centerX = self.arrowLocationCustomized ? self.arrowLocation : self.backgroundView.center.x;
    self.arrowView.center = CGPointMake(centerX, self.arrowView.center.y);
    
    // Close Button
    self.closeButton.frame = CGRectMake(CGRectGetMaxX(self.backgroundView.bounds) - kOnboardingTipViewCloseButtonSize, 0.0, kOnboardingTipViewCloseButtonSize, kOnboardingTipViewCloseButtonSize);
    self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(-kOnboardingTipViewCloseButtonImageInset, kOnboardingTipViewCloseButtonImageInset, 0.0, 0.0);
    
    // Tip Text View
    self.tipTextView.frame = CGRectMake(kOnboardingTipPaddingHorizontal,
                                        kOnboardingTipPaddingVertical,
                                        CGRectGetWidth(backgroundViewFrame) - (2*kOnboardingTipPaddingHorizontal),
                                        CGRectGetHeight(backgroundViewFrame) - (2*kOnboardingTipPaddingVertical));
    
    // Wrap the text around close button's image.
    CGRect closeImageFrame = [self.closeButton convertRect:self.closeButton.imageView.frame toView:self.backgroundView];
    // Add some padding to the exclusion path since we don't want it too close to button's image.
    closeImageFrame.origin.x -= kOnboardingTipPaddingHorizontal;
    closeImageFrame.origin.y -= kOnboardingTipPaddingHorizontal;
    closeImageFrame.size.width += kOnboardingTipPaddingHorizontal;
    UIBezierPath *closeButtonPath = [UIBezierPath bezierPathWithRect:closeImageFrame];
    self.tipTextView.textContainer.exclusionPaths = @[closeButtonPath];
}

#pragma mark - Accessor Methods

- (void)setArrowDirection:(SFOnboardingTipViewArrowDirection)arrowDirection {
    if (_arrowDirection != arrowDirection) {
        _arrowDirection = arrowDirection;
        
        [self setNeedsLayout];
    }
}

- (void)setMaximumSize:(CGSize)maximumSize {
    _maximumSize.width = maximumSize.width == 0.0 ? kOnboardingTipViewMaxWidth : maximumSize.width;
    _maximumSize.height = maximumSize.height == 0.0 ? kOnboardingTipViewMaxHeight : maximumSize.height;
}

- (void)setTip:(NSString *)tip {
    if (![tip isEqualToString:_tip]) {
        _tip = tip;
        
        self.tipTextView.text = _tip;
        [self adjustLayoutBasedOnTipText];
    }
}

#pragma mark - Private Methods

/* This method calculates the number of lines needed based on the tip, and adjusts the size of the frame appropriately. */
- (void)adjustLayoutBasedOnTipText {
    CGFloat originalWidth = self.bounds.size.width;
    CGFloat desiredWidth = originalWidth;
    CGFloat extraSpace = 2*kOnboardingTipPaddingHorizontal + 2*self.closeButton.imageView.image.size.width;
    CGSize tipSize = [self.tip sizeWithAttributes:@{NSFontAttributeName: self.tipTextView.font}];
    NSInteger numberOfLines = 0;
    
    // Determine the most appropriate width.
    if (originalWidth < self.maximumSize.width) {
        CGFloat requiredWidth = tipSize.width + extraSpace;
        if (requiredWidth > originalWidth && requiredWidth < self.maximumSize.width) {
            // If required width is somewhere between min width and max width, use required width.
            desiredWidth = requiredWidth;
        } else {
            // Otherwise set desired width to max width if needed.
            numberOfLines = ceilf(tipSize.width / (originalWidth - extraSpace));
            // If we can't fit the text in 1 line, set the width to max possible size.
            if (numberOfLines > 1) {
                desiredWidth = self.maximumSize.width;
            }
        }
    } else {
        desiredWidth = self.maximumSize.width;
    }
    
    // Recalculate number of lines if desired width is different than original width.
    if (desiredWidth != originalWidth) {
        numberOfLines = ceilf(tipSize.width / (desiredWidth - extraSpace));
    }
    
    // Adjust width and height of the view based on desired width and number of lines.
    CGRect frame = self.frame;
    CGFloat originalHeight = frame.size.height;
    
    frame.size.width = desiredWidth;
    frame.origin.x -= ((frame.size.width - originalWidth) / 2);
    frame.size.height = MIN(ceilf(self.tipTextView.font.lineHeight * numberOfLines) + 2*kOnboardingTipPaddingVertical, self.maximumSize.height) + self.arrowView.image.size.height;
    if (self.arrowDirection == SFOnboardingTipViewArrowDirectionDown) {
        frame.origin.y -= (frame.size.height - originalHeight);
    }
    
    self.frame = CGRectIntegral(frame);
}

#pragma mark - Public Methods

- (CGRect)setTipAndAdjustFrame:(NSString *)tip {
    self.tip = [tip copy];
    
    return self.frame;
}

- (void)setArrowLocation:(CGFloat)arrowLocation {
    if (_arrowLocation!= arrowLocation) {
        _arrowLocation = arrowLocation;
        self.arrowLocationCustomized = YES;
    }
}

- (void)setAction:(SEL)action forTarget:(id)target {
    if (action != nil && target != nil) {
        [self.tipTextView removeGestureRecognizer:self.tapGesture];
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self.tipTextView addGestureRecognizer:self.tapGesture];
    }
}

@end
