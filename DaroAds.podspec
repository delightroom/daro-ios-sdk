Pod::Spec.new do |spec|
  spec.name = 'DaroAds'
  spec.version = '1.0.7'
  spec.summary = 'Ad network mediation sdk for iOS.'
  spec.description = <<-DESC
                      Daro is is a SDK that helps you to easily integrate multiple ad networks into your app.
                      DESC
  spec.homepage = 'https://delightroom.com'
  spec.license = { :type => 'Custom' }
  spec.author = { 'Won Jo' => 'lion@delightroom.com' }
  spec.source = { :http => "https://github.com/delightroom/Daro-iOS-SDK/releases/download/#{spec.version}/Daro.xcframework.zip" }
  spec.swift_version = '5.7'
  spec.ios.deployment_target = '14.1'

  spec.resource_bundles = {
    'DaroAdsResources' => ['Daro.xcframework/ios-arm64/Daro.framework/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'Daro.xcframework'

  spec.dependency 'Google-Mobile-Ads-SDK', '11.3.0'

  # Google Admob partner networks
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.15.1.0'     # Meta
  spec.dependency 'GoogleMobileAdsMediationPangle', '6.2.0.8.0'      # Pangle
  spec.dependency 'GoogleMobileAdsMediationInMobi', '10.7.4.0'       # Inmobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.2.8.0'         # DT Exchange
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.7.0.0'    # Chatboost
  spec.dependency 'GoogleMobileAdsMediationAppLovin', '12.4.1.0'     # AppLovin
  spec.dependency 'GoogleMobileAdsMediationIronSource', '8.0.0.0.0'  # IronSource
  spec.dependency 'GoogleMobileAdsMediationVungle', '7.4.2.0'      # Vungle
  spec.dependency 'GoogleMobileAdsMediationMintegral', '7.6.2.0'     # Mintegral

  # Verve(HyBid)
  spec.dependency 'GoogleMobileAds-HyBid-Adapters', '3.0.2.1'

  # PubMatic
  spec.dependency 'OpenWrapSDK', '3.5.1'
  spec.dependency 'AdMobPubMaticAdapter', '3.0.0'

  # Smaato
  spec.dependency 'smaato-ios-sdk/Banner', '22.8.4'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Banner', '11.3.0.0'

  spec.dependency 'smaato-ios-sdk/Interstitial', '22.8.4'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Interstitial', '11.3.0.0'

  spec.dependency 'smaato-ios-sdk/RewardedAds', '22.8.4'
  spec.dependency 'smaato-ios-sdk-mediation-admob/RewardedAds', '11.3.0.0'

  spec.dependency 'smaato-ios-sdk/Modules/Interstitial', '22.8.4'
  spec.dependency 'smaato-ios-sdk/Modules/RichMedia', '22.8.4'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Interstitial', '11.3.0.0'

  spec.dependency 'smaato-ios-sdk/Native', '22.8.4'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Native', '11.3.0.0'

  # APS
  spec.dependency 'AmazonPublisherServicesSDK', '4.9.4'

end
