
# T-Mobile customized version of Apptentive iOS SDK

## Basic information

* T-Mobile customized version of Apptentive SDK is maintained as Cocoa Pod named __apptentive-ios-tmo__.
* Spec for __apptentive-ios-tmo__ is stored at https://github.com/productrealization/tmo-app-pod-specs
* Apptentive versions it's SDK with a 3 number format (e.g. 4.0.7) so we version it by adding fourth number (e.g. 4.0.7.1). This way we know which apptentive-ios version our release is based on.
* Our customizations are stored in branch `tmo-app-customizations`

## HOWTO
### How to use apptentive-ios-tmo in my app
1. Setup CocoaPods for your project
2. Put `source 'https://github.com/productrealization/tmo-app-pod-specs.git'` at the top of your Podfile
3. Add `pod 'apptentive-ios-tmo', TMOApptentiveVersion` to your target in your Podfile (TMOApptentiveVersion must be defined e.g. `TMOApptentiveVersion = '4.0.7.1'`)
3. `pod repo update`
4. `pod install`

### How to upgrade apptentive-ios-tmo with latest changes from upstream apptentive-ios
1. For convenience `git remote add upstream https://github.com/apptentive/apptentive-ios`
2. Pull master from upstream (github.com/apptentive/apptentive-ios)
3. Now you need to apply `tmo-app-customizations` branch no top of master. There are many options to do that.
 * You can merge `master` branch to `tmo-app-customizations` 
 * You can rebase `tmo-app-customizations` on top of `master` but be aware that this will re-write history
 * You can cherry-pick commits from `tmo-app-customizations` to some new branch.
4. Whichever option you choose you will then need to release new version of apptentive-ios-tmo pod which is described in the next howto

### How to release new version of apptentive-ios-tmo
1. Do your changes in the code
2. Bump pod version number in apptentive-ios-tmo.podspec file
3. Commit this change to your branch
4. `pod lib lint apptentive-ios-tmo.podspec --verbose --allow-warnings`
5. If everything is fine tag this commit with your version number. e.g. `v4.0.7.2`. The `v` is important. Podspec file defines how the tag must look like in order to be used by CocoaPods for versioning.
6. Push the tag
7. \[Optional\] Only do it if you haven't done it on your machine yet. `pod repo add TMOAppPodSpecs git@github.com:productrealization/tmo-app-pod-specs.git`
8. `pod repo push TMOAppPodSpecs apptentive-ios-tmo.podspec --verbose --allow-warnings`
9. Verify that podspec for new version of the pod is visible at https://github.com/productrealization/tmo-app-pod-specs
10. Update version of apptentive-ios-tmo in you app's Podfile and run `pod install`


# Original README starts here
# Apptentive iOS SDK

The Apptentive iOS SDK provides a simple and powerful channel to communicate in-app with your customers.

Use Apptentive features to improve your app's App Store ratings, collect and respond to customer feedback, show surveys at specific points within your app, and more.

## Install Guide

Apptentive can be installed manually as an Xcode subproject or via the dependency manager CocoaPods.

The following guides explain the integration process:

 - [Xcode project setup guide](http://www.apptentive.com/docs/ios/setup/xcode/)
 - [CocoaPods installation guide](http://www.apptentive.com/docs/ios/setup/cocoapods)
 
 As of version 3.3.1, we also support Carthage. 

## Using Apptentive in your App

After integrating the Apptentive SDK into your project, you can [begin using Apptentive features in your app](http://www.apptentive.com/docs/ios/integration/).

To begin using the SDK, import the SDK and create a configuration object with your Apptentive App Key and Apptentive App Signature (found in the [API section of your Apptentive dashboard](https://be.apptentive.com/apps/current/settings/api)).

``` objective-c
@import Apptentive;
...
ApptentiveConfiguration = [ApptentiveConfiguration configurationWithApptentiveKey:@"<#Your Apptentive App Key#>" apptentiveSignature:@"<#Your Apptentive App Signature#>"];
[Apptentive registerWithConfiguration:configuration];
...
[Apptentive.shared engage:@"event_name", from: viewController];
```

Or, in Swift:

``` Swift
import Apptentive
...
if let configuration = ApptentiveConfiguration(apptentiveKey: "<#Your Apptentive App Key#>", apptentiveSignature: "<#Your Apptentive App Signature#>") {
	Apptentive.register(with: configuration)
}
...
Apptentive.shared.engage(event: "event_name", from: viewController)
```

Later, on your Apptentive dashboard, you will target these events with Apptentive features such as Message Center, Ratings Prompts, and Surveys.

Please see our [iOS integration guide](http://www.apptentive.com/docs/ios/integration/) for more on this subject.

## API Documentation

Please see our docs site for the Apptentive iOS SDK's [API documentation](http://www.apptentive.com/docs/ios/api/Classes/Apptentive.html).

Apptentive's [API changelog](docs/APIChanges.md) is also updated with each release of the SDK.

## Testing Apptentive Features

Please see the [Apptentive testing guide](http://www.apptentive.com/docs/ios/testing/) for directions on how to test that the Rating Prompt, Surveys, and other Apptentive features have been configured correctly.

# Apptentive Example App

To see an example of how the Apptentive iOS SDK can be integrated with your app, take a look at the `iOSExample` app in the `Example` directory in this repository.

The example app shows you how to integrate using CocoaPods, set your Apptentive App Key and Apptentive App Signature, engage events, and integrate with Message Center. See the `README.md` file in the `Example` directory for more information.

## Contributing

Our client code is completely [open source](LICENSE.txt), and we welcome contributions to the Apptentive SDK! If you have an improvement or bug fix, please first read our [contribution agreement](CONTRIBUTING.md).

## Reporting Issues

If you experience an issue with the Apptentive SDK, please [open a GitHub issue](https://github.com/apptentive/apptentive-ios/issues?direction=desc&sort=created&state=open).

If the request is urgent, please contact <mailto:support@apptentive.com>.
