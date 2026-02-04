Pod::Spec.new do |s|
  s.name             = 'daro_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Daro Flutter SDK'
  s.description      = 'Daro Flutter SDK'
  s.homepage         = 'https://github.com/delightroom/daro-flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Delightroom' => 'dev@delightroom.so' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.static_framework = true
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.dependency 'DaroAds', '1.1.50'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
