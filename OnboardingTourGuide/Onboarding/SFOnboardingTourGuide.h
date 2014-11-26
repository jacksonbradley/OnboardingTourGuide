//
//  SFOnboardingTourGuide.h
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

#import <UIKit/UIKit.h>
#import "SFOnboardingDelegate.h"

/**
 * A flag used to indicate the condition for showing the tip.
 * SFOnboardingConditionShowOnce        - Show this tip only once.
 * SFOnboardingConditionShowEverytime   - Show this tip every time.
 * SFOnboardingConditionShowIfAged      - Show only if the tip was shown before a certain date and time.
 *                                        @see SFOnboardingDelegate method tourGuide:requiredAgeForTip: to learn how to specify the age.
 */
typedef NS_ENUM(NSInteger, SFOnboardingCondition) {
    SFOnboardingConditionShowOnce,
    SFOnboardingConditionShowEverytime,
    SFOnboardingConditionShowIfAged
};

/**
 * The arrow direction for the tip.
 * SFOnboardingArrowDirectionDown   - Tip shows above the view, with the arrow pointing down.
 * SFOnboardingArrowDirectionUp     - Tip shows below the view, with the arrow pointing up.
 */
typedef NS_ENUM(NSInteger, SFOnboardingArrowDirection) {
    SFOnboardingArrowDirectionDown,
    SFOnboardingArrowDirectionUp
};

// The default delay for showing a tip.
extern CGFloat const SFOnboardingTourGuideDefaultDelay;

// The key used for saving the relevant information about each tip in user default. You can use this to reset all the tips by removing it from user defaults.
extern NSString * const SFOnboardingTourGuideContainerKey;

// You can use this key to enable/disable showing the tips.
extern NSString * const SFOnboardingTourGuideEnabledKey;

/**
 * A tour guide object can be used to display onboarding tips.
 */
@interface SFOnboardingTourGuide : NSObject

@property (nonatomic, weak) id<SFOnboardingDelegate> delegate;

/**
 * Display an onboarding tip.
 * @param tipIdentifier  An app-wide unique tip identifier used for this specific tip.
 * @param forView        The view for which the tip is being displayed.
 * @param inView         The tip will be added as a subview of this view. Typically inView is the superview of forView.
 * @param condition      A flag used for indicating the condition for showing the tip.
 * @param arrowDirection The preferred arrow direction for the tip. If set to down, the tip appears above forView. If set to up, the tip appears below forView.
 *                       If the specified arrow direction causes the view to be outside the inView bounds, the arrow direction will be switched to a more appropritate option.
 * @param animated       If YES, animates the presentation of the tip; otherwise, does not.
 * @param delayInSeconds The number of seconds to delay showing the tip. Specify 0 to immediately show the tip.
 */
- (void)showTip:(NSString *)tipIdentifier forView:(UIView *)forView inView:(UIView *)inView condition:(SFOnboardingCondition)condition arrowDirection:(SFOnboardingArrowDirection)arrowDirection withDelay:(CGFloat)delayInSeconds animated:(BOOL)animated;

/**
 * Dismiss the currently visible tip.
 * @param animated Pass in YES to fade away the tip view.
 */
- (void)dismissTip:(BOOL)animated;

/**
 * Redisplays the current tip.
 * You can use this method to make sure the tip is brought to the front and is positioned correctly in case a change has occured to the view.
 */
- (void)redisplayCurrentTip;

@end
