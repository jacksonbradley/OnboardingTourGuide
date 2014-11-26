//
//  MainViewController.m
//  OnboardingTourGuide
//
//  Created by Behzad Richey on 10/17/14.

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

#import "MainViewController.h"
#import "SFOnboardingTourGuide.h"

static NSString * const SFOnboardingTipButton     = @"SFOnboardingTipButton";
static NSString * const SFOnboardingTipReset      = @"SFOnboardingTipReset";
static NSString * const SFOnboardingTipSalesforce = @"SFOnboardingTipSalesforce";
static NSString * const SFOnboardingTipFoundation = @"SFOnboardingTipFoundation";

@interface MainViewController () <SFOnboardingDelegate>

@property (nonatomic) BOOL resetTips;

@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UIImageView *testImageView;

@property (nonatomic, strong) SFOnboardingTourGuide *tourGuide;

@end

@implementation MainViewController

- (id)init {
    self = [super init];
    
    if (self) {
        self.tourGuide = [[SFOnboardingTourGuide alloc] init];
        self.tourGuide.delegate = self;
        
        self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.resetButton.backgroundColor = [UIColor colorWithRed:0.976 green:0.588 blue:0.361 alpha:1.000];
        self.resetButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        self.resetButton.titleLabel.textColor = [UIColor whiteColor];
        [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.resetButton addTarget:self action:@selector(showFirstTip:) forControlEvents:UIControlEventTouchUpInside];
        
        self.testButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.testButton.backgroundColor = [UIColor colorWithRed:0.624 green:0.506 blue:0.922 alpha:1.000];
        self.testButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.testButton setTitle:@"Tap Here" forState:UIControlStateNormal];
        [self.testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.testButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.testButton addTarget:self action:@selector(testButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.testImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"salesforce_logo"]];
        self.testImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:self.resetButton];
        [self.view addSubview:self.testButton];
        [self.view addSubview:self.testImageView];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.testButton.frame = CGRectMake(20.0, 80.0, 100.0, 30.0);
    
    CGRect imageViewFrame = self.testImageView.frame;
    CGFloat imageRatio = CGRectGetWidth(self.testImageView.bounds) / CGRectGetHeight(self.testImageView.bounds);
    imageViewFrame.origin.x = CGRectGetMinX(self.testButton.frame);
    imageViewFrame.origin.y = CGRectGetMaxY(self.testButton.frame) + 20.0;
    imageViewFrame.size.width = CGRectGetWidth(self.view.bounds) - 40.0;
    imageViewFrame.size.height = ceilf(CGRectGetWidth(imageViewFrame) / imageRatio);
    self.testImageView.frame = imageViewFrame;
    
    self.resetButton.frame = CGRectMake(20.0, CGRectGetMaxY(self.testImageView.frame) + 20.0, CGRectGetWidth(self.testImageView.frame), 30.0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showFirstTip:nil];
}

#pragma mark - Private Methods

- (void)showFirstTip:(id)sender {
    if (sender == self.resetButton) {
        self.resetTips = YES;
        [self.tourGuide dismissTip:YES];
    }
    [self.tourGuide showTip:SFOnboardingTipButton
                    forView:self.testButton
                     inView:self.view
                  condition:SFOnboardingConditionShowEverytime
             arrowDirection:SFOnboardingArrowDirectionUp
                  withDelay:SFOnboardingTourGuideDefaultDelay
                   animated:YES];
}

- (void)testButtonTapped:(id)sender {
    [self.tourGuide dismissTip:YES];
}

#pragma mark - SFOnboardingDelegate

- (NSString *)tourGuide:(SFOnboardingTourGuide *)tourGuide messageForTip:(NSString *)tipIdentifier {
    NSString *tip = nil;
    
    if ([tipIdentifier isEqualToString:SFOnboardingTipButton]) {
        tip = @"This is the first tip. Tap this button or dismiss this message to view more tips!";
    } else if ([tipIdentifier isEqualToString:SFOnboardingTipSalesforce]) {
        tip = @"Salesforce is a global cloud computing company headquartered in San Francisco, California. Tap the 'X' to see the next tip.";
    } else if ([tipIdentifier isEqualToString:SFOnboardingTipFoundation]) {
        tip = @"The Salesforce Foundation donates 1% of company's resources (equity, employee time, and product) to help improve communites around the world.";
    } else if ([tipIdentifier isEqualToString:SFOnboardingTipReset]) {
        tip = @"Tap this button to start over!";
    }
    
    return tip;
}

// Use this delegate method to chain tips together by showing one, after another is dismissed.
- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide didDismissTip:(NSString *)tipIdentifier explicitlyDismissed:(BOOL)flag {
    if (flag || !self.resetTips) {
        if ([tipIdentifier isEqualToString:SFOnboardingTipButton]) {
            [self.tourGuide showTip:SFOnboardingTipSalesforce
                            forView:self.testImageView
                             inView:self.view
                          condition:SFOnboardingConditionShowEverytime
                     arrowDirection:SFOnboardingArrowDirectionUp
                          withDelay:0.0
                           animated:YES];
        } else if ([tipIdentifier isEqualToString:SFOnboardingTipSalesforce]) {
            [self.tourGuide showTip:SFOnboardingTipFoundation
                            forView:self.testImageView
                             inView:self.view
                          condition:SFOnboardingConditionShowEverytime
                     arrowDirection:SFOnboardingArrowDirectionDown
                          withDelay:0.0
                           animated:YES];
        } else if ([tipIdentifier isEqualToString:SFOnboardingTipFoundation]) {
            [self.tourGuide showTip:SFOnboardingTipReset
                            forView:self.resetButton
                             inView:self.view
                          condition:SFOnboardingConditionShowEverytime
                     arrowDirection:SFOnboardingArrowDirectionUp
                          withDelay:0.0
                           animated:YES];
        }
    }
}

- (void)tourGuide:(SFOnboardingTourGuide *)tourGuide didShowTip:(NSString *)tipIdentifier {
    if ([tipIdentifier isEqualToString:SFOnboardingTipButton]) {
        self.resetTips = NO;
    }
}

@end
