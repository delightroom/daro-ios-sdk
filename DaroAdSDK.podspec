Pod::Spec.new do |spec|
  spec.name = 'DaroAdSDK'
  spec.version = '1.0.0'
  spec.summary = 'Daro Ad SDK for iOS - Standalone ad serving SDK'
  spec.description = <<-DESC
                      DaroAdSDK is a lightweight ad serving SDK that provides banner, interstitial, and native ad formats without third-party network dependencies.
                      DESC
  spec.homepage = 'https://delightroom.com'
  spec.license = { :type => 'Custom' }
  spec.author = { 'Won Jo' => 'lion@delightroom.com' }
  spec.source = { :http => "https://github.com/delightroom/daro-ios-sdk/releases/download/#{spec.version}/DaroAdSDK.xcframework.zip" }
  spec.swift_version = '5.7'
  spec.ios.deployment_target = '13.0'

  spec.resource_bundles = {
    'DaroAdSDKResources' => ['DaroAdSDK.xcframework/ios-arm64/DaroAdSDK.framework/PrivacyInfo.xcprivacy']
  }

  spec.static_framework = true
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.vendored_frameworks = 'DaroAdSDK.xcframework'

  # OMID (Open Measurement SDK) for viewability measurement
  spec.dependency 'OMSDK_Mintegral', '1.5.1'

end
