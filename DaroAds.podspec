Pod::Spec.new do |spec|
  spec.name = 'DaroAds'
  spec.version = '1.1.65'
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

  # [RTB] PrebidMobile SPM 리소스 번들(mraid.js / omsdk.js) 동봉.
  # 런타임에 Bundle.module 이 앱 번들에서 PrebidMobile_PrebidMobile.bundle 을 찾으므로 as-is 로 복사.
  # RTB(prebid) 통합 라인 전용 — production main 에는 두지 않음.
  spec.resources = ['Daro.xcframework/ios-arm64/Daro.framework/PrebidMobile_PrebidMobile.bundle']

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'Daro.xcframework'

  spec.dependency 'Google-Mobile-Ads-SDK', '13.0.0'

  # Google Admob partner networks
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.21.0.2'     # Meta
  spec.dependency 'GoogleMobileAdsMediationPangle', '7.9.0.6.0'      # Pangle
  spec.dependency 'GoogleMobileAdsMediationInMobi', '11.1.1.1'       # InMobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.4.4.1'         # DT Exchange
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.11.0.3'   # Chartboost
  spec.dependency 'GoogleMobileAdsMediationAppLovin', '13.6.0.0'     # AppLovin
  spec.dependency 'GoogleMobileAdsMediationIronSource', '9.3.0.0.1'  # IronSource
  spec.dependency 'GoogleMobileAdsMediationVungle', '7.7.0.0'        # Liftoff (Vungle)
  spec.dependency 'GoogleMobileAdsMediationMintegral', '8.0.7.0'     # Mintegral
  spec.dependency 'GoogleMobileAdsMediationMoloco', '4.5.0.0'        # Moloco
  spec.dependency 'GoogleMobileAdsMediationLine', '3.0.0.1'          # Line (FiveAd)
  spec.dependency 'GoogleMobileAdsMediationUnity', '4.16.6.1'        # Unity
  spec.dependency 'GoogleMobileAdsMediationPubMatic', '4.12.0.0'     # PubMatic

end
