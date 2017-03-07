//
//  ApptentiveInteractionAppleRatingDialogController.m
//  Apptentive
//
//  Created by Frank Schmitt on 3/6/17.
//  Copyright © 2017 Apptentive, Inc. All rights reserved.
//

#import "ApptentiveInteractionAppleRatingDialogController.h"
#import "ApptentiveInteraction.h"
#import <StoreKit/StoreKit.h>

NSString *const ApptentiveInteractionAppleRatingDialogEventLabelRequest = @"request";
NSString *const ApptentiveInteractionAppleRatingDialogEventLabelShown = @"shown";
NSString *const ApptentiveInteractionAppleRatingDialogEventLabelNotShown = @"not_shown";

#define REVIEW_WINDOW_TIMEOUT (int64_t)(1.0 * NSEC_PER_SEC)

@implementation ApptentiveInteractionAppleRatingDialogController

+ (void)load {
	[self registerInteractionControllerClass:self forType:@"AppleRatingDialog"];
}

- (void)presentInteractionFromViewController:(UIViewController *)viewController {
	[self.interaction engage:ApptentiveInteractionAppleRatingDialogEventLabelRequest fromViewController:viewController];

	BOOL appleRatingDialogAvailable = NO;

	// Make sure we can compile on pre-10.3 SDKs
#ifdef __IPHONE_10_3
	// Avoid crashing if mistakenly launched on a pre-10.3 system
	appleRatingDialogAvailable = [SKStoreReviewController class] != nil;
#endif

	if (!appleRatingDialogAvailable) {
		[self.interaction engage:ApptentiveInteractionAppleRatingDialogEventLabelNotShown fromViewController:viewController userInfo:@{ @"cause": @"unavailable" }];

		return;
	}

	// Assume the review request will not be shown…
	__block NSString *result = ApptentiveInteractionAppleRatingDialogEventLabelNotShown;

	// …but listen for new windows whose class name starts with "SKStoreReview"
	id<NSObject> notifier = [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeVisibleNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
		if ([NSStringFromClass([note.object class]) hasPrefix:@"SKStoreReview"]) {
			// Review window was shown
			result = ApptentiveInteractionAppleRatingDialogEventLabelShown;
		}
	}];

	// This may or may not display a review window
	[SKStoreReviewController requestReview];

	// Give the window a sec to appear
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, REVIEW_WINDOW_TIMEOUT), dispatch_get_main_queue(), ^{
		// Indicate whether a window was shown
		[self.interaction engage:result fromViewController:viewController];

		[[NSNotificationCenter defaultCenter] removeObserver:notifier];
	});
}

@end
