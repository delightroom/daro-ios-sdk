Pod::Spec.new do |spec|
  spec.name = 'DaroAds'
  spec.version = '1.1.41-alpha'
  spec.summary = 'Ad network mediation sdk for iOS.'
  spec.description = <<-DESC
                      Daro is is a SDK that helps you to easily integrate multiple ad networks into your app.
                      DESC
  spec.homepage = 'https://delightroom.com'
  spec.license = { :type => 'Custom' }
  spec.author = { 'Won Jo' => 'lion@delightroom.com' }
  spec.source = { :http => "https://github.com/delightroom/Daro-iOS-SDK/releases/download/#{spec.version}/Daro.xcframework.zip" }
  spec.swift_version = '5.7'
  spec.ios.deployment_target = '13.0'

  spec.resource_bundles = {
    'DaroAdsResources' => ['Daro.xcframework/ios-arm64/Daro.framework/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'Daro.xcframework'

  spec.dependency 'Google-Mobile-Ads-SDK', '12.2.0'

  # Google Admob partner networks
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.17.1.0'     # Meta
  spec.dependency 'GoogleMobileAdsMediationPangle', '6.5.0.9.0'      # Pangle
  spec.dependency 'GoogleMobileAdsMediationInMobi', '10.8.2.0'       # Inmobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.3.7.0'         # DT Exchange
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.8.1.0'    # Chatboost
  spec.dependency 'GoogleMobileAdsMediationAppLovin', '13.2.0.0'     # AppLovin
  spec.dependency 'GoogleMobileAdsMediationIronSource', '8.8.0.0.0'  # IronSource
  spec.dependency 'GoogleMobileAdsMediationVungle', '7.4.5.0'        # Vungle
  spec.dependency 'GoogleMobileAdsMediationMintegral', '7.7.7.0'     # Mintegral
  spec.dependency 'GoogleMobileAdsMediationMoloco', '3.9.1.0'        # Moloco
  spec.dependency 'GoogleMobileAdsMediationLine', '2.9.20241106.3'   # Line (FiveAd)

  # Verve(HyBid)
  spec.dependency 'GoogleMobileAds-HyBid-Adapters', '3.2.0.1'

  # PubMatic
  spec.dependency 'OpenWrapSDK', '4.6.0'
  spec.dependency 'AdMobPubMaticAdapter', '5.0.0'

  # Smaato
  spec.dependency 'smaato-ios-sdk/Banner', '22.9.3'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Banner', '12.2.0.0'

  spec.dependency 'smaato-ios-sdk/Interstitial', '22.9.3'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Interstitial', '12.2.0.0'

  spec.dependency 'smaato-ios-sdk/RewardedAds', '22.9.3'
  spec.dependency 'smaato-ios-sdk-mediation-admob/RewardedAds', '12.2.0.0'

  spec.dependency 'smaato-ios-sdk/Modules/Interstitial', '22.9.3'
  spec.dependency 'smaato-ios-sdk/Modules/RichMedia', '22.9.3'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Interstitial', '12.2.0.0'

  spec.dependency 'smaato-ios-sdk/Native', '22.9.3'
  spec.dependency 'smaato-ios-sdk-mediation-admob/Native', '12.2.0.0'

  # APS
  spec.dependency 'AmazonPublisherServicesSDK', '5.1.0'

end
