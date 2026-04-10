Pod::Spec.new do |spec|
  spec.name         = 'DaroObjCBridge'
  spec.version      = '1.1.55-alpha'
  spec.summary      = 'Objective-C Bridge for Daro iOS SDK'
  spec.description  = <<-DESC
                      Objective-C compatible wrapper for Daro iOS SDK.
                      Provides native Objective-C interfaces for all Daro ad formats.
                      DESC
  spec.homepage     = 'https://github.com/delightroom/daro-ios-sdk'
  spec.license      = { :type => 'Commercial', :text => 'Copyright (c) Delightroom. All rights reserved.' }
  spec.author       = { 'Delightroom' => 'dev@delightroom.co.kr' }
  spec.source       = {
    :http => "https://github.com/delightroom/daro-ios-sdk/releases/download/#{spec.version}/DaroObjCBridge.xcframework.zip"
  }

  spec.platform              = :ios
  spec.ios.deployment_target = '13.0'
  spec.swift_version         = '5.7'

  spec.resource_bundles = {
    'DaroObjCBridgeResources' => ['DaroObjCBridge.xcframework/ios-arm64/DaroObjCBridge.framework/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'DaroObjCBridge.xcframework'

  spec.dependency 'Google-Mobile-Ads-SDK', '12.14.0'

  # Google Admob partner networks
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.21.0.1'     # Meta
  spec.dependency 'GoogleMobileAdsMediationPangle', '7.8.5.7.0'      # Pangle
  spec.dependency 'GoogleMobileAdsMediationInMobi', '11.1.0.1'       # Inmobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.4.3.0'         # DT Exchange
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.11.0.1'   # Chatboost
  spec.dependency 'GoogleMobileAdsMediationAppLovin', '13.5.0.0'     # AppLovin
  spec.dependency 'GoogleMobileAdsMediationIronSource', '9.2.0.0.1'  # IronSource
  spec.dependency 'GoogleMobileAdsMediationVungle', '7.6.3.1'        # Vungle
  spec.dependency 'GoogleMobileAdsMediationMintegral', '8.0.5.1'     # Mintegral
  spec.dependency 'GoogleMobileAdsMediationMoloco', '4.3.0.0'        # Moloco
  spec.dependency 'GoogleMobileAdsMediationLine', '2.9.20251119.1'   # Line (FiveAd)
  spec.dependency 'GoogleMobileAdsMediationUnity', '4.16.5.0'        # Unity
end
