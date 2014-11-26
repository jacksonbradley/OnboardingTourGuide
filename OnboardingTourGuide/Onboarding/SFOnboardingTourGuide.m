//
//  SFOnboardingTourGuide.m
//  InsightsSDK
//
//  Created by Behzad Richey on 7/17/14.

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

#import "SFOnboardingTourGuide.h"
#import "SFOnboardingTipView.h"

static BOOL const SFOnboardingTourGuideAutoRotate = NO;

static CGFloat const kOnboardingViewMinWidth = 180.0;
static CGFloat const kOnboardingViewMinHeight = 35.0;
static CGFloat const kOnboardingViewSidePadding = 14.0;
static CGFloat const kOnboardingViewTipSeparation = 5.0;

CGFloat const SFOnboardingTourGuideDefaultDelay = 0.5;

NSString * const SFOnboardingTourGuideContainerKey = @"SFOnboardingTourGuideContainerKey";
NSString * const SFOnboardingTourGuideEnabledKey   = @"SFOnboardingTourGuideEnabledKey";

@interface SFOnboardingTourGuide ()

/** Use this boolean to keep track of whether arrow direction was changed automatically, so we don't get stuck in a loop trying to re-adjust the position of tip view. */
@property (nonatomic) BOOL autoChangedArrowDirection;

@property (nonatomic) SFOnboardingTipViewArrowDirection arrowDirection;
@property (nonatomic, strong) NSString *currentTip;
@property (nonatomic, weak) UIView *anchorView;

@property (nonatomic, strong) SFOnboardingTipView *tipView;

@property (nonatomic) UIInterfaceOrientation currentOrientation;

@end

@implementation SFOnboardingTourGuide

- (id)init {
    self = [super init];
    
    if (self) {
        if (SFOnboardingTourGuideAutoRotate) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplayCurrentTip:) name:UIDeviceOrientationDidChangeNotification object:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    if (SFOnboardingTourGuideAutoRotate) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

#pragma mark - Public Methods

- (void)showTip:(NSString *)tipIdentifier forView:(UIView *)forView inView:(UIView *)inView condition:(SFOnboardingCondition)condition arrowDirection:(SFOnboardingArrowDirection)arrowDirection withDelay:(CGFloat)delayInSeconds animated:(BOOL)animated {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        SFOnboardingTipViewArrowDirection direction = (arrowDirection == SFOnboardingArrowDirectionDown) ? SFOnboardingTipViewArrowDirectionDown : SFOnboardingTipViewArrowDirectionUp;
        [self showTip:tipIdentifier forView:forView inView:inView condition:condition arrowDirection:direction animated:animated];
    });
}

- (void)dismissTip:(BOOL)animated {
    [self dismissTip:animated explicitlyDismissed:NO];
}

- (void)redisplayCurrentTip {
    UIView *inView = self.tipView.superview;
    UIView *anchorView = self.anchorView;
    NSString *currentTip = self.currentTip;
    
    if (!inView) {
        return;
    } else {
        [self removeTip];
    }
    
    [self showTip:currentTip forView:anchorView inView:inView condition:SFOnboardingConditionShowEverytime arrowDirection:self.arrowDirection animated:NO];
}

#pragma mark - Private Methods

- (void)redisplayCurrentTip:(NSNotification *)notification {
    // Only trigger a redisplay if the orientation is actually different than the orientation when the tip was initially displayed.
    if (self.currentOrientation != [self interfaceOrientation]) {
        [self redisplayCurrentTip];
    }
}

- (void)showTip:(NSString *)tipIdentifier forView:(UIView *)forView inView:(UIView *)inView condition:(SFOnboardingCondition)condition arrowDirection:(SFOnboardingTipViewArrowDirection)arrowDirection animated:(BOOL)animated {
    if ([self tipsDisabled]) {
        return;
    }
    
    if (![self isConditionMet:condition tipIdentifier:tipIdentifier] || forView == nil || inView == nil) {
        [self delegateTipNotQualifiedToDisplay:tipIdentifier];
        return;
    }
    
    BOOL showTip = [self delegateWillShowTip:tipIdentifier];
    if (!showTip) {
        // Don't show the tip if delegate says no.
        return;
    }
    
    // Dismiss the current tip (if there is one), before presenting a new tip.
    [self dismissTip:NO explicitlyDismissed:NO];
    
    CGFloat yOrigin = 0.0;
    CGRect forViewFrame = [inView convertRect:forView.frame fromView:forView.superview];
    if (arrowDirection == SFOnboardingArrowDirectionDown) {
        yOrigin = CGRectGetMinY(forViewFrame) - kOnboardingViewMinHeight - kOnboardingViewTipSeparation;
    } else {
        yOrigin = CGRectGetMaxY(forViewFrame) + kOnboardingViewTipSeparation;
    }
    
    CGRect tipViewFrame = CGRectMake(0.0, yOrigin, kOnboardingViewMinWidth, kOnboardingViewMinHeight);
    self.tipView = [[SFOnboardingTipView alloc] initWithFrame:tipViewFrame withArrowDirection:arrowDirection];
    [self.tipView.closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat availableWidth = CGRectGetWidth(inView.frame) - 2*kOnboardingViewSidePadding;
    if (availableWidth < self.tipView.maximumSize.width) {
        self.tipView.maximumSize = CGSizeMake(availableWidth, 0.0);
    }
    
    // Set the tip message and check to make sure the new frame is within bounds of inView.
    CGRect newFrame = [self.tipView setTipAndAdjustFrame:[self delegateMessageForTip:tipIdentifier]];
    if (newFrame.origin.y < 0.0 && arrowDirection == SFOnboardingTipViewArrowDirectionDown) {
        if (!self.autoChangedArrowDirection) {
            // If we can't place the tip view above forView, then try changing the arrow direction and placing it below forView.
            self.autoChangedArrowDirection = YES;
            self.tipView = nil;
            [self showTip:tipIdentifier forView:forView inView:inView condition:condition arrowDirection:SFOnboardingTipViewArrowDirectionUp animated:animated];
            return;
        } else {
            // If a second attempt failed, set the arrow direction back to the original direction and align the top of tip view with the top of forView.
            self.tipView.arrowDirection = SFOnboardingTipViewArrowDirectionUp;
            arrowDirection = SFOnboardingTipViewArrowDirectionUp;
            tipViewFrame = self.tipView.frame;
            tipViewFrame.origin.y = CGRectGetMaxY(forViewFrame) - tipViewFrame.size.height;
            self.tipView.frame = tipViewFrame;
        }
    } else if (CGRectGetMaxY(newFrame) > inView.frame.size.height && arrowDirection == SFOnboardingTipViewArrowDirectionUp) {
        if (!self.autoChangedArrowDirection) {
            // If we can't place the tip view below forView, then try changing the arrow direction and placing it above forView.
            self.autoChangedArrowDirection = YES;
            self.tipView = nil;
            [self showTip:tipIdentifier forView:forView inView:inView condition:condition arrowDirection:SFOnboardingTipViewArrowDirectionDown animated:animated];
            return;
        } else {
            // If a second attempt failed, set the arrow direction back to the original direction and align the bottom of tip view with the bottom of forView.
            self.tipView.arrowDirection = SFOnboardingTipViewArrowDirectionDown;
            arrowDirection = SFOnboardingTipViewArrowDirectionDown;
            tipViewFrame = self.tipView.frame;
            tipViewFrame.origin.y = CGRectGetMinY(forViewFrame);
            self.tipView.frame = tipViewFrame;
        }
    }
    
    self.autoChangedArrowDirection = NO;
    
    self.anchorView = forView;
    self.arrowDirection = arrowDirection;
    self.currentOrientation = [self interfaceOrientation];
    self.currentTip = tipIdentifier;
    
    [self.tipView setAction:@selector(delegateTipWasTapped:) forTarget:self];
    
    // Adjust the location for tip view and its arrow.
    CGPoint center = [inView convertPoint:forView.center fromView:forView.superview];
    self.tipView.center = CGPointMake(center.x, self.tipView.center.y);
    // Make sure tipView is still within the bounds of inView.
    CGFloat xMax = 0.0;
    if ([inView isKindOfClass:[UIScrollView class]]) {
        xMax = ((UIScrollView *)inView).contentSize.width;
    } else {
        xMax = CGRectGetMaxX(inView.frame);
    }
    tipViewFrame = self.tipView.frame;
    if (CGRectGetMinX(tipViewFrame) < kOnboardingViewSidePadding) {
        tipViewFrame.origin.x = kOnboardingViewSidePadding;
        self.tipView.frame = tipViewFrame;
    } else if (CGRectGetMaxX(tipViewFrame) > xMax - kOnboardingViewSidePadding) {
        tipViewFrame.origin.x -= (CGRectGetMaxX(tipViewFrame) - xMax + kOnboardingViewSidePadding);
        self.tipView.frame = tipViewFrame;
    }
    
    [inView addSubview:self.tipView];
    
    center = [self.tipView convertPoint:center fromView:inView];
    [self.tipView setArrowLocation:center.x];
    
    [self saveDateForIdentifier:tipIdentifier];
    
    void (^completionBlock)(BOOL) = ^void(BOOL finished) {
        [self delegateDidShowTip:tipIdentifier];
    };
    
    if (animated) {
        self.tipView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.tipView.alpha = 1.0;
                         }
                         completion:completionBlock];
    } else {
        completionBlock(YES);
    }
}

- (void)dismissTip:(BOOL)animated explicitlyDismissed:(BOOL)flag {
    if (!self.tipView.superview) {
        return;
    }
    
    [self delegateWillDismissTip:flag];
    
    void (^completionBlock)(BOOL) = ^void(BOOL finished) {
        [self delegateDidDismissTip:flag];
    };
    
    if (!animated) {
        completionBlock(YES);
        return;
    }
    
    dispatch_block_t animationBlock = ^{
        self.tipView.alpha = 0.0;
    };
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:animationBlock
                     completion:completionBlock];
}

- (IBAction)closeTapped:(id)sender {
    [self dismissTip:YES explicitlyDismissed:YES];
}

- (BOOL)isConditionMet:(SFOnboardingCondition)condition tipIdentifier:(NSString *)tipIdentifier {
    BOOL conditionMet = NO;
    
    if (!tipIdentifier) {
        return NO;
    }
    
    switch (condition) {
        case SFOnboardingConditionShowOnce:
            if (![self lastDateForTip:tipIdentifier]) {
                conditionMet = YES;
            }
            break;
            
        case SFOnboardingConditionShowIfAged: {
            NSDate *lastDate = [self lastDateForTip:tipIdentifier];
            NSUInteger requiredAge = [self delegateAgeForTip:tipIdentifier];
            NSTimeInterval ageInSeconds = requiredAge * 86400;
            if ([[lastDate dateByAddingTimeInterval:ageInSeconds] timeIntervalSinceDate:lastDate] > ageInSeconds) {
                conditionMet = YES;
            }
            
            break;
        }
            
        case SFOnboardingConditionShowEverytime:
            conditionMet = YES;
            break;
            
        default:
            break;
    }
    
    return conditionMet;
}

- (BOOL)tipsDisabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SFOnboardingTourGuideEnabledKey];
}

- (NSDate *)lastDateForTip:(NSString *)tipIdentifier {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *onboardingDictionary = [userDefaults dictionaryForKey:SFOnboardingTourGuideContainerKey];
    return onboardingDictionary[tipIdentifier];
}

- (void)saveDateForIdentifier:(NSString *)identifier {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *onboardingDictionary = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:SFOnboardingTourGuideContainerKey]];
    onboardingDictionary[identifier] = [NSDate date];
    
    [userDefaults setObject:onboardingDictionary forKey:SFOnboardingTourGuideContainerKey];
    [userDefaults synchronize];
}

- (void)removeTip {
    [self.tipView removeFromSuperview];
    self.tipView = nil;
    self.anchorView = nil;
    self.currentTip = nil;
}

- (UIInterfaceOrientation)interfaceOrientation {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)deviceOrientation;
    if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        orientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return orientation;
}

#pragma mark - Delegate Wrapper Methods

- (NSString *)delegateMessageForTip:(NSString *)tipIdentifier {
    NSString *message = @"";
    
    if ([self.delegate respondsToSelector:@selector(tourGuide:messageForTip:)]) {
        message = [self.delegate tourGuide:self messageForTip:tipIdentifier];
    }
    
    return message;
}

- (NSUInteger)delegateAgeForTip:(NSString *)tipIdentifier {
    NSUInteger age = NSNotFound;
    
    if ([self.delegate respondsToSelector:@selector(tourGuide:requiredAgeForTip:)]) {
        age = [self.delegate tourGuide:self requiredAgeForTip:tipIdentifier];
    }
    
    return age;
}

- (void)delegateTipWasTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tourGuide:tipWasTapped:)] && self.currentTip) {
        [self.delegate tourGuide:self tipWasTapped:self.currentTip];
    }
}

- (BOOL)delegateWillShowTip:(NSString *)tipIdentifier {
    BOOL showTip = YES;
    
    if ([self.delegate respondsToSelector:@selector(tourGuide:willShowTip:)]) {
        showTip = [self.delegate tourGuide:self willShowTip:tipIdentifier];
    }
    
    return showTip;
}

- (void)delegateTipNotQualifiedToDisplay:(NSString *)tipIdentifier {
    if ([self.delegate respondsToSelector:@selector(tourGuide:tipNotQualifiedToDisplay:)]) {
        [self.delegate tourGuide:self tipNotQualifiedToDisplay:tipIdentifier];
    }
}

- (void)delegateDidShowTip:(NSString *)tipIdentifier {
    if ([self.delegate respondsToSelector:@selector(tourGuide:didShowTip:)]) {
        [self.delegate tourGuide:self didShowTip:tipIdentifier];
    }
}

- (void)delegateWillDismissTip:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(tourGuide:willDismissTip:explicitlyDismissed:)] && self.currentTip && self.tipView.superview) {
        [self.delegate tourGuide:self willDismissTip:self.currentTip explicitlyDismissed:flag];
    }
}

- (void)delegateDidDismissTip:(BOOL)flag {
    if (!self.tipView.superview) {
        return;
    }
    
    NSString *tipIdentifier = self.currentTip;
    [self removeTip];
    
    if ([self.delegate respondsToSelector:@selector(tourGuide:didDismissTip:explicitlyDismissed:)] && tipIdentifier) {
        [self.delegate tourGuide:self didDismissTip:tipIdentifier explicitlyDismissed:flag];
    }
}

@end
