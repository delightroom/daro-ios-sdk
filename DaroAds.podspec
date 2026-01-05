Pod::Spec.new do |spec|
  spec.name = 'DaroAds'
  spec.version = '1.1.49'
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
  spec.dependency 'GoogleMobileAdsMediationUnity', '4.16.1.0'	     # Unity

  # APS
  spec.dependency 'AmazonPublisherServicesSDK', '5.3.0'

end
