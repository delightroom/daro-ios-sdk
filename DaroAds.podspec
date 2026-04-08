Pod::Spec.new do |spec|
  spec.name = 'DaroAds'
  spec.version = '1.1.55-alpha'
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
  spec.dependency 'GoogleMobileAdsMediationUnity', '4.16.5.0'	     # Unity

end
