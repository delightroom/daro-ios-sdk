Pod::Spec.new do |spec|
  spec.name         = 'DaroMObjCBridge'
  spec.version      = '1.1.44'
  spec.summary      = 'Objective-C Bridge for DaroM iOS SDK'
  spec.description  = <<-DESC
                      Objective-C compatible wrapper for DaroM iOS SDK.
                      Provides native Objective-C interfaces for all DaroM ad formats.
                      DESC
  spec.homepage     = 'https://github.com/delightroom/daro-ios-sdk'
  spec.license      = { :type => 'Commercial', :text => 'Copyright (c) Delightroom. All rights reserved.' }
  spec.author       = { 'Delightroom' => 'dev@delightroom.co.kr' }
  spec.source       = {
    :http => "https://github.com/delightroom/daro-ios-sdk/releases/download/#{spec.version}/DaroMObjCBridge.xcframework.zip"
  }

  spec.platform              = :ios
  spec.ios.deployment_target = '13.0'
  spec.swift_version         = '5.7'

  spec.resource_bundles = {
    'DaroMObjCBridgeResources' => ['DaroMObjCBridge.xcframework/ios-arm64/DaroMObjCBridge.framework/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = false
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'DaroMObjCBridge.xcframework'

  spec.dependency 'AppLovinSDK', '13.4.0'
  spec.dependency 'AppLovinMediationGoogleAdapter', '12.8.0.0'
  spec.dependency 'AppLovinMediationFacebookAdapter', '6.20.1.0'
  spec.dependency 'AppLovinMediationByteDanceAdapter', '7.6.0.6.0'
  spec.dependency 'AppLovinMediationInMobiAdapter', '10.8.6.0'
  spec.dependency 'AppLovinMediationVungleAdapter', '7.5.3.0'
  spec.dependency 'AppLovinMediationFyberAdapter', '8.4.1.0'
  spec.dependency 'AppLovinMediationMintegralAdapter', '7.7.9.0.0'
  spec.dependency 'AmazonPublisherServicesSDK', '5.3.0'
  spec.dependency 'AppLovinMediationAmazonAdMarketplaceAdapter', '5.3.0.0'
  spec.dependency 'AppLovinMediationVerveAdapter', '3.7.0.0'
  spec.dependency 'AppLovinMediationIronSourceAdapter', '8.11.0.0.0'
  spec.dependency 'AppLovinMediationUnityAdsAdapter', '4.16.1.0'
  spec.dependency 'AppLovinMediationSmaatoAdapter', '22.9.3.1'
  spec.dependency 'AppLovinMediationMolocoAdapter', '3.12.1.0'
  spec.dependency 'AppLovinMediationLineAdapter', '2.9.20250912.0'
  spec.dependency 'AppLovinMediationChartboostAdapter', '9.9.2.1'
  spec.dependency 'AppLovinMediationOguryPresageAdapter', '5.1.0.1'
end
