//
//  SFOnboardingDelegate.h
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

#import <Foundation/Foundation.h>

@class SFOnboardingTourGuide;

/**
 * The delegate of an SFOnboardingTourGuide must adopt the SFOnboardingDelegate protocol.
 */
@protocol SFOnboardingDelegate <NSObject>

@required

/**
 * Required method to be implemented by the delegate.
 * This method is used to return the tip message based on the tip ID.
 * @param tourGuide     The tour guide object requesting this information.
 * @param tipIdentifier The tip ID used to distinguish each tip
 * @return The tip message to be shown.
 */
- (NSString *)tourGuide:(SFOnboardingTourGuide *)tourGuide messageForTip:(NSString *)tipIdentifier;

@optional

/**
 * The delegate must implement this method if a tip is used which requires a conditional tip based on age.
 * The age is measured in number of days. For example, an age of 30 is equivalent to 30 days.
 * @param tourGuide     The tour guide object requesting this information.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 * @return The age requirement for a tip, in number of days.
 */
- (NSUInteger)tourGuide:(SFOnboardingTourGuide *)tourGuide requiredAgeForTip:(NSString *)tipIdentifier;

/**
 * Notifies the delegate that the tip was tapped by the user.
 * The delegate can implement this method to take action when a tip is tapped on by the user.
 * Note: Tapping the tip will not dismiss the tip. If desired, the delegate can use this method to dismiss the tip as well.
 * @param tourGuide     The tour guide object that is sending this message.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 */
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide tipWasTapped:(NSString *)tipIdentifier;

/**
 * Will let the delegate know if a tip does not qualify to be shown due to not meeting the necessary condition(s).
 * @param tourGuide     The tour guide object that will not show the tip.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 */
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide tipNotQualifiedToDisplay:(NSString *)tipIdentifier;

/**
 * Notifies the delegate that the tip will be shown.
 * This method also gives the delegate a chance to cancel showing the tip.
 * @param tourGuide     The tour guide object that will dismiss the tip.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 * @return YES to continue showing the tip. NO if delegate does not want the tip to be shown.
 */
- (BOOL)tourGuide:(SFOnboardingTourGuide *)tourGuide willShowTip:(NSString *)tipIdentifier;

/**
 * Notifies the delegate that the tip was shown.
 * @param tourGuide     The tour guide object that will dismiss the tip.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 */
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide didShowTip:(NSString *)tipIdentifier;

/**
 * Notifies the delegate that the tip will be dismissed.
 * @param tourGuide     The tour guide object that will dismiss the tip.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 * @param flag          YES if tip is being dismissed as a result of user tapping on the close button.
 */
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide willDismissTip:(NSString *)tipIdentifier explicitlyDismissed:(BOOL)flag;

/**
 * Notifies the delegate that the tip has been dismissed.
 * @param tourGuide     The tour guide object that dismissed the tip.
 * @param tipIdentifier The tip ID used to distinguish each tip.
 * @param flag          YES if tip was dismissed as a result of user tapping on the close button.
 */
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide didDismissTip:(NSString *)tipIdentifier explicitlyDismissed:(BOOL)flag;

@end
