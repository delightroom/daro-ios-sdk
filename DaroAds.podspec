Pod::Spec.new do |spec|
  spec.name         = 'DaroAds'
  spec.version      = '0.5.0'
  spec.summary      = 'Ad network mediation sdk for iOS.'
  spec.description  = <<-DESC
                      Daro is is a SDK that helps you to easily integrate multiple ad networks into your app.
                      It supports AdMob and other ad networks.
                      DESC
  spec.homepage     = 'https://delightroom.com'
  spec.license      = { :type => 'Custom' }
  spec.author       = { 'Won Jo' => 'lion@delightroom.com' }
  spec.source       = { :http => "https://github.com/delightroom/Daro-iOS-SDK/releases/download/#{spec.version}/Daro.xcframework.zip" }
  spec.swift_version = '5.7'
  spec.ios.deployment_target = '14.1'

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'Daro.xcframework'

  spec.dependency 'Google-Mobile-Ads-SDK', '10.4.0' # AdMob
  spec.dependency 'GoogleMobileAdsMediationInMobi', '10.5.4.0' # InMobi
  spec.dependency 'GoogleMobileAdsMediationFyber', '8.2.1.0' # Fyber
  spec.dependency 'GoogleMobileAdsMediationChartboost', '9.3.0' # Chartboost
  spec.dependency 'GoogleMobileAdsMediationPangle', '5.1.1.0' # Pangle
  spec.dependency 'GoogleMobileAdsMediationFacebook', '6.12.0.1' # Meta

  spec.dependency 'AdMobPubMaticAdapter', '2.2.0' # PubMatic
  spec.dependency 'GoogleMobileAds-HyBid-Adapters', '2.18.1.1' # Verve
  # spec.dependency 'AmazonPublisherServicesAdMobAdapter', '3.0.2' # Amazon

end
