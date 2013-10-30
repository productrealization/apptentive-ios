//
//  ATInteractionUpgradeMessageViewController.m
//  ApptentiveConnect
//
//  Created by Peter Kamb on 10/16/13.
//  Copyright (c) 2013 Apptentive, Inc. All rights reserved.
//

#import "ATInteractionUpgradeMessageViewController.h"
#import "ATConnect_Private.h"
#import "ATInteraction.h"
#import "ATBackend.h"
#import "ATMessagePanelViewController.h"
#import "ATUtilities.h"
#import "UIImage+ATImageEffects.h"

typedef enum {
	ATInteractionUpgradeMessageOkPressed,
} ATInteractionUpgradeMessageAction;

@interface ATInteractionUpgradeMessageViewController ()
- (UIWindow *)findMainWindowPreferringMainScreen:(BOOL)preferMainScreen;
- (UIWindow *)windowForViewController:(UIViewController *)viewController;
- (void)statusBarChanged:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applyRoundedCorners;
@end

@implementation ATInteractionUpgradeMessageViewController

- (id)initWithInteraction:(ATInteraction *)interaction {
	NSAssert([interaction.type isEqualToString:@"UpgradeMessage"], @"Attempted to load an UpgradeMessageViewController with an interaction of type: %@", interaction.type);
	self = [super initWithNibName:@"ATInteractionUpgradeMessageViewController" bundle:[ATConnect resourceBundle]];
	if (self != nil) {
		_upgradeMessageInteraction = interaction;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Blurred background
	// 10% black over background image
	UIImage *screenshot = [ATUtilities imageByTakingScreenshot];
	UIColor *tintColor = [UIColor colorWithWhite:0 alpha:0.1];
	UIImage *blurred = [screenshot at_applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
	[self.backgroundImageView setImage:blurred];
	
	// App icon
	if ([[self.upgradeMessageInteraction.configuration objectForKey:@"show_app_icon"] boolValue]) {
		self.appIconContainer.hidden = NO;
		[self.appIconView setImage:[ATUtilities appIcon]];
		[self.appIconBackgroundView setImage:[ATBackend imageNamed:@"at_update_icon_shadow"]];
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.appIconContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
		[self.appIconContainer addConstraint:constraint];
		// Rounded corners
		UIImage *maskImage = [ATBackend imageNamed:@"at_update_icon_mask"];
		CALayer *maskLayer = [[CALayer alloc] init];
		maskLayer.contents = (id)maskImage.CGImage;
		maskLayer.frame = (CGRect){CGPointZero, self.appIconView.bounds.size};
		self.appIconView.layer.mask = maskLayer;
		[maskLayer release], maskLayer = nil;
	} else {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.appIconContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
		[self.appIconContainer addConstraint:constraint];
		self.appIconContainer.hidden = YES;
	}
	
	// Powered by Apptentive logo
	if ([[self.upgradeMessageInteraction.configuration objectForKey:@"show_powered_by"] boolValue]) {
		self.poweredByApptentiveLogo.text = ATLocalizedString(@"Powered by", @"Powered by followed by Apptentive logo.");
		self.poweredByApptentiveIconView.contentMode = UIViewContentModeScaleAspectFit;
		UIImage *poweredByApptentiveIcon = [ATBackend imageNamed:@"at_update_logo"];
		[self.poweredByApptentiveIconView setImage:poweredByApptentiveIcon];
		self.poweredByBackground.hidden = NO;
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.poweredByBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
		[self.poweredByBackground addConstraint:constraint];
	} else {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.poweredByBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
		[self.poweredByBackground addConstraint:constraint];
		self.poweredByBackground.hidden = YES;
	}
		
	// Web view
	NSString *html = [self.upgradeMessageInteraction.configuration objectForKey:@"body"];
	[self.webView loadHTMLString:html baseURL:nil];
	
	[self applyRoundedCorners];
}

- (IBAction)okButtonPressed:(id)sender {
	//[self.delegate messagePanelDidCancel:self];
	[self dismissAnimated:YES completion:NULL withAction:ATInteractionUpgradeMessageOkPressed];
	//[[NSNotificationCenter defaultCenter] postNotificationName:ATMessageCenterIntroDidCancelNotification object:self userInfo:nil];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion withAction:(ATInteractionUpgradeMessageAction)action {
	CGRect newFrame = self.alertView.frame;
	CGPoint offscreenCenter = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame) - (newFrame.origin.y + newFrame.size.height));
	
	CGRect poweredByEndingFrame = self.poweredByBackground.frame;
	poweredByEndingFrame = CGRectOffset(self.poweredByBackground.frame, 0, poweredByEndingFrame.size.height);
		
	CGFloat duration = 0;
	if (animated) {
		duration = 0.3;
	}
	
	[UIView animateWithDuration:duration animations:^(void){
		self.alertView.center = offscreenCenter;
		self.backgroundImageView.alpha = 0.0;
		self.poweredByBackground.frame = poweredByEndingFrame;
	} completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		[presentingViewController.view setUserInteractionEnabled:YES];
		[self.window resignKeyWindow];
		[self.window removeFromSuperview];
		self.window.hidden = YES;
		//[[UIApplication sharedApplication] setStatusBarStyle:startingStatusBarStyle];
		//[self teardown];
		[self release];
		
		if (completion) {
			completion();
		}
		//[self.delegate messagePanel:self didDismissWithAction:action];
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentFromViewController:(UIViewController *)newPresentingViewController animated:(BOOL)animated {
	[self retain];
	// For viewDidLoad…
	__unused UIView *v = [self view];
	
	if (presentingViewController != newPresentingViewController) {
		[presentingViewController release], presentingViewController = nil;
		presentingViewController = [newPresentingViewController retain];
		[presentingViewController.view setUserInteractionEnabled:NO];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	
		
	UIWindow *parentWindow = [self windowForViewController:presentingViewController];
	if (!parentWindow) {
		ATLogError(@"Unable to find parentWindow!");
	}
	if (originalPresentingWindow != parentWindow) {
		[originalPresentingWindow release], originalPresentingWindow = nil;
		originalPresentingWindow = [parentWindow retain];
	}
		
	CGRect animationBounds = CGRectZero;
	CGPoint animationCenter = CGPointZero;
	
	CGAffineTransform t = [ATUtilities viewTransformInWindow:parentWindow];
	self.window.transform = t;
	self.window.hidden = NO;
	[parentWindow resignKeyWindow];
	[self.window makeKeyAndVisible];
	animationBounds = parentWindow.bounds;
	animationCenter = parentWindow.center;
	
	// Animate in from above.
	self.window.bounds = animationBounds;
	self.window.windowLevel = UIWindowLevelNormal;
	CGPoint center = animationCenter;
	center.y = ceilf(center.y);
	
	CGRect endingFrame = originalPresentingWindow.bounds;//[[UIScreen mainScreen] applicationFrame];
	
	[self positionInWindow];

	self.window.center = CGPointMake(CGRectGetMidX(endingFrame), CGRectGetMidY(endingFrame));
	
	CGRect poweredByEndingFrame = self.poweredByBackground.frame;
	self.poweredByBackground.frame = CGRectOffset(poweredByEndingFrame, 0, poweredByEndingFrame.size.height);
	
	CGRect newFrame = self.alertView.frame;
	self.alertView.center = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame) - (newFrame.origin.y + newFrame.size
																							.height));
	CGPoint newViewCenter = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame));
	
	CALayer *l = self.alertView.layer;
	l.cornerRadius = 10.0;
	l.backgroundColor = [UIColor clearColor].CGColor;
	l.masksToBounds = YES;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	} else {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	}
	self.backgroundImageView.alpha = 0;
	[UIView animateWithDuration:0.3 animations:^(void){
//		self.window.center = newViewCenter;
		self.window.frame = animationBounds;
		self.alertView.center = newViewCenter;
		self.poweredByBackground.frame = poweredByEndingFrame;
		self.backgroundImageView.alpha = 1;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		self.window.hidden = NO;
	}];
		
	//[[NSNotificationCenter defaultCenter] postNotificationName:ATMessageCenterIntroDidShowNotification object:self userInfo:nil];
}

- (BOOL)isIPhoneAppInIPad {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		NSString *model = [[UIDevice currentDevice] model];
		if ([model isEqualToString:@"iPad"]) {
			return YES;
		}
	}
	return NO;
}

- (void)positionInWindow {
	CGAffineTransform t = [ATUtilities viewTransformInWindow:originalPresentingWindow];
	self.window.transform = t;
	self.window.frame = originalPresentingWindow.bounds;
	[self.appIconView layoutIfNeeded];
	[self.backgroundImageView layoutIfNeeded];
	[self.poweredByBackground layoutIfNeeded];
	[self.alertView layoutIfNeeded];
	[self.contentView layoutIfNeeded];
	/*
	UIView *v = self.appIconView;
	while ((v = (UIView *)v.superview)) {
		[v layoutSubviews];
	}
	 */
	
	[self applyRoundedCorners];
}

- (UIWindow *)findMainWindowPreferringMainScreen:(BOOL)preferMainScreen {
	UIApplication *application = [UIApplication sharedApplication];
	for (UIWindow *tmpWindow in [[application windows] reverseObjectEnumerator]) {
		if (tmpWindow.rootViewController || tmpWindow.isKeyWindow) {
			if (preferMainScreen && [tmpWindow respondsToSelector:@selector(screen)]) {
				if (tmpWindow.screen && [tmpWindow.screen isEqual:[UIScreen mainScreen]]) {
					return tmpWindow;
				}
			} else {
				return tmpWindow;
			}
		}
	}
	return nil;
}

- (UIWindow *)windowForViewController:(UIViewController *)viewController {
	UIWindow *result = nil;
	UIView *rootView = [viewController view];
	if (rootView.window) {
		result = rootView.window;
	}
	if (!result) {
		result = [self findMainWindowPreferringMainScreen:YES];
		if (!result) {
			result = [self findMainWindowPreferringMainScreen:NO];
		}
	}
	return result;
}

- (void)statusBarChanged:(NSNotification *)notification {
	[self positionInWindow];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (self.window.hidden == NO) {
		[self retain];
		[self unhide:NO];
	}
	[pool release], pool = nil;
}

- (void)applyRoundedCorners {
	// Rounded top corners of content
	UIBezierPath *contentMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
	CAShapeLayer *contentMaskLayer = [CAShapeLayer layer];
	contentMaskLayer.frame = self.webView.bounds;
	contentMaskLayer.path = contentMaskPath.CGPath;
	self.contentView.layer.mask = contentMaskLayer;
	
	// Rounded bottom corners of OK button
	UIBezierPath *buttonMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.okButtonBackgroundView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
	CAShapeLayer *buttonMaskLayer = [CAShapeLayer layer];
	buttonMaskLayer.frame = self.okButtonBackgroundView.bounds;
	buttonMaskLayer.path = buttonMaskPath.CGPath;
	self.okButtonBackgroundView.layer.mask = buttonMaskLayer;
}

- (void)unhide:(BOOL)animated {
	self.window.windowLevel = UIWindowLevelNormal;
	self.window.hidden = NO;
	if (animated) {
		[UIView animateWithDuration:0.2 animations:^(void){
			self.window.alpha = 1.0;
		} completion:^(BOOL complete){
			[self finishUnhide];
		}];
	} else {
		[self finishUnhide];
	}
}

- (void)hide:(BOOL)animated {
	[self retain];
	
	self.window.windowLevel = UIWindowLevelNormal;
	
	if (animated) {
		[UIView animateWithDuration:0.2 animations:^(void){
			self.window.alpha = 0.0;
		} completion:^(BOOL finished) {
			[self finishHide];
		}];
	} else {
		[self finishHide];
	}
}

- (void)finishHide {
	self.window.alpha = 0.0;
	self.window.hidden = YES;
	[self.window removeFromSuperview];
}

- (void)finishUnhide {
	self.window.alpha = 1.0;
	[self.window makeKeyAndVisible];
	[self positionInWindow];
	[self release];
}
- (void)dealloc {
	[_contentView release];
	[_poweredByBackground release];
	[_appIconBackgroundView release];
	[_poweredByApptentiveLogo release];
	[_appIconContainer release];
	[super dealloc];
}
- (void)viewDidUnload {
	[self setContentView:nil];
	[self setPoweredByBackground:nil];
	[self setAppIconBackgroundView:nil];
	[self setPoweredByApptentiveLogo:nil];
	[self setAppIconContainer:nil];
	[super viewDidUnload];
}
@end