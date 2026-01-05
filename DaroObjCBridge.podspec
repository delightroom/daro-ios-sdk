Pod::Spec.new do |spec|
  spec.name         = 'DaroObjCBridge'
  spec.version      = '1.2.4-internal'
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

  spec.dependency 'Google-Mobile-Ads-SDK', '12.8.0'

  # Google Admob partner networks
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.20.1.0'     # Meta
  spec.dependency 'GoogleMobileAdsMediationPangle', '7.6.0.6.0'      # Pangle
  spec.dependency 'GoogleMobileAdsMediationInMobi', '10.8.6.0'       # Inmobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.4.1.0'         # DT Exchange
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.9.2.0'    # Chatboost
  spec.dependency 'GoogleMobileAdsMediationAppLovin', '13.4.0.0'     # AppLovin
  spec.dependency 'GoogleMobileAdsMediationIronSource', '8.11.0.0.0' # IronSource
  spec.dependency 'GoogleMobileAdsMediationVungle', '7.5.3.0'        # Vungle
  spec.dependency 'GoogleMobileAdsMediationMintegral', '7.7.9.0'     # Mintegral
  spec.dependency 'GoogleMobileAdsMediationMoloco', '3.12.1.0'       # Moloco
  spec.dependency 'GoogleMobileAdsMediationLine', '2.9.20250912.0'   # Line (FiveAd)
  spec.dependency 'GoogleMobileAdsMediationUnity', '4.16.1.0'        # Unity

  # APS
  spec.dependency 'AmazonPublisherServicesSDK', '5.3.0'
end
