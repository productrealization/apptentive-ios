Pod::Spec.new do |s|
  s.name     = 'apptentive-ios-tmo'
  s.module_name = 'Apptentive'
  s.version  = '4.0.7.1'
  s.license  = 'BSD'
  s.summary  = 'Apptentive Customer Communications SDK.'
  s.homepage = 'https://www.apptentive.com/'
  s.authors  = { 'Apptentive SDK Team' => 'sdks@apptentive.com' }
  s.source   = { :git => 'https://github.com/productrealization/apptentive-ios.git', :tag => "v#{s.version}" }
  s.platform = :ios, '8.0'
  s.source_files   = 'Apptentive/Apptentive/**/*.{h,m}'
  s.requires_arc = true
  s.frameworks     = 'AVFoundation', 'CoreData', 'CoreGraphics', 'Foundation', 'ImageIO', 'MobileCoreServices', 'QuartzCore', 'QuickLook', 'SystemConfiguration', 'UIKit'
  s.resource_bundle = { 'ApptentiveResources' => [
		'Apptentive/Apptentive/Model/*.xcdatamodeld',
		'Apptentive/Apptentive/Model/*.xcmappingmodel',
		'Apptentive/Apptentive/localization/*.lproj',
		'Apptentive/Apptentive/Images/**/*.*',
		'Apptentive/Apptentive/Apptentive.storyboard'
		] }
  s.weak_frameworks = 'StoreKit', 'CoreTelephony'
  s.prefix_header_contents = '#import "ApptentiveLog.h"', '#import "ApptentiveAssert.h"', '#import "ApptentiveSafeCollections.h"'
  s.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS[config=Debug]" => "APPTENTIVE_DEBUG=1 APPTENTIVE_COCOAPODS=1",
  "GCC_PREPROCESSOR_DEFINITIONS[config=Release]" => "APPTENTIVE_COCOAPODS=1" }
  s.public_header_files = 'Apptentive/Apptentive/Apptentive.h', 'Apptentive/Apptentive/ApptentiveStyleSheet.h'
end
