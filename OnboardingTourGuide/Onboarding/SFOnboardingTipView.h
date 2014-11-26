//
//  SFOnboardingTipView.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SFOnboardingTipViewArrowDirection) {
    SFOnboardingTipViewArrowDirectionDown,
    SFOnboardingTipViewArrowDirectionUp
};

/**
 * The view used for displaying onboarding tips.
 */
@interface SFOnboardingTipView : UIView

@property (nonatomic) SFOnboardingTipViewArrowDirection arrowDirection;

@property (nonatomic, strong, readonly) UIButton *closeButton;

@property (nonatomic) CGSize maximumSize;

/**
 * Initializes and returns a newly allocated tip view object with the specified frame rectangle and arrow direction.
 * @param frame          The frame rectangle for the view, measured in points.
 * @param arrowDirection The desired arrow direction, either up or down.
 */
- (id)initWithFrame:(CGRect)frame withArrowDirection:(SFOnboardingTipViewArrowDirection)arrowDirection;

/**
 * This method sets the tip message, and returns the new frame for the view based on the size needed to display the tip message properly.
 * @param tip The tip message to be displayed.
 */
- (CGRect)setTipAndAdjustFrame:(NSString *)tip;

/**
 * Set the horizontal location for the arrow.
 * By default, the arrow is horizontally aligned to the center of the tip view. You can use this method to essentially
 * set the center x of the arrow view to a different point as desired.
 * @param arrowLocation A CGFloat value indicating the center x of the arrow location with respect to the tip view.
 */
- (void)setArrowLocation:(CGFloat)arrowLocation;

/**
 * Add an action to the tip view for a single tap gesture.
 * @param action A selector identifying an action message. It cannot be NULL.
 * @param target The target object to which the action message is sent.
 */
- (void)setAction:(SEL)action forTarget:(id)target;

@end
