OnboardingTourGuide
===================

An easy-to-use API that allows you to add onboarding tips anywhere in your application. SFOnboardingTourGuide allows you to display onboarding tips depending on whether the specific tip qualifies to be shown at a given point in time.

![Onboaring Example](https://github.com/SalesforceEng/OnboardingTourGuide/raw/master/Gif/onboarding.gif)

How to Use:
===========
1. Clone this project:
```
git clone https://github.com/SalesforceEng/OnboardingTourGuide.git
```
2. Place the folder `OnboardingTourGuide/Onboarding` in your project.
3. Import `SFOnboardingTourGuide`:
```
#import "SFOnboardingTourGuide.h"
```
4. Have your class conform to `SFOnboardingDelegate`.
5. Instantiate your tour guide and set its delegate:
```
self.tourGuide = [SFOnboardingDelegate alloc] init];
self.tourGuide.delegate = self;
```
6. Tell the tour guide to show the tip when appropriate:
```
[self.tourGuide showTip:@"SFOnboardingTipMagicButton" forView:self.magicButton inView:self.view condition:SFOnboardingConditionShowOnce arrowDirection:SFOnboardingArrowDirectionDown withDelay:SFOnboardingTourGuideDefaultDelay animated:YES];
```
7. Implement the required delegate method to let the delegate know what message to show:
```
- (NSString *)tourGuide:(SFOnboardingTourGuide *)tourGuide messageForTip:(NSString *)tipIdentifier {
    NSString *tip = nil;

    if ([tipIdentifier isEqualToString:@"SFOnboardingTipMagicButton"]) {
        tip = @"Tap on this button and magic will happen!";
    }

    return tip;
}
```

More Options
============
There are two main ways in which you can determine whether to show a tip at a given point at run-time:

1. SFOnboardingCondition:
  + SFOnboardingConditionShowOnce &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_The tip is only shown once_
  + SFOnboardingConditionShowEverytime &nbsp;&nbsp;_The tip is shown every time_
  + SFOnboardingConditionShowIfAged &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_The tip is displayed only if it was last shown before a certain date and time_


2. Implement the delegate method `tourGuide:willShowTip:` in order to let the tour guide know if you still want to show the tip or not. This method gives you a chance to check the state of your application to see if showing the tip is still appropriate.


> SFOnboardingDelegate provides many useful methods which you can implement to further customize the behavior of the onboarding tip. Refer to `SFOnboardingDelegate.h` for some helpful documentation.

> Refer to the documentation in SFOnboardingTourGuide.h for more ways in which you can manipulate the onboarding tips.

#####To see an example of how to utilize SFOnboardingTourGuide, clone this repository and open the OnboardingTourGuide project in Xcode.
