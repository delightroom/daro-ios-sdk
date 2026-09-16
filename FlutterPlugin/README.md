# Daro Flutter SDK

## 자동 네이티브 설정

플랫폼별 기존 키 파일과 App Key를 준비하고 앱 루트에 `daro.yaml`을 작성합니다.
`daro.example.yaml`을 참고하세요. iOS에는 AdMob App ID도 필요합니다.

```yaml
ios:
  app_key: "YOUR_IOS_DARO_APP_KEY"
  admob_app_id: "ca-app-pub-0000000000000000~0000000000"
  key_file: "keys/ios-daro-key.txt"
android:
  app_key: "YOUR_ANDROID_DARO_APP_KEY"
  key_file: "keys/android-daro-key.txt"
```

```bash
dart run daro_flutter:configure
dart run daro_flutter:doctor
```

필요한 플랫폼만 지정할 수 있습니다. 키 파일 경로는 앱 루트 기준입니다.
configure는 키 파일 복사, iOS Runner 리소스 등록·Info.plist·SKAdNetwork·Podfile,
Android 저장소·플러그인·desugaring·최소 SDK를 설정합니다.
Flutter 1.0.6 배포본의 네이티브 의존 버전과 빌드 설정을 유지합니다.
소비자 앱의 minSdk는 daro-compose-util 1.3.1의 요구사항과 1.0.6 예제에 맞춰 24 이상으로 설정합니다.
iOS 설정에는 macOS, CocoaPods, `xcodeproj` gem을 불러올 수 있는 Ruby가 필요합니다.

기본 Android app 모듈과 단일 iOS Runner 앱을 지원합니다.
Android는 AGP 8.x를 사용하세요. 1.0.6 예제의 도구 조합은 AGP 8.7.0, Gradle 8.10.2, Kotlin 2.0.21입니다.
AGP 9는 기존 광고 라이브러리의 중복 namespace로 지원하지 않으며 doctor에서 안내합니다. flavor·별도 plist·기존 수동
Daro 플러그인 설정은 자동 변경 전에 진단합니다. 키 파일과 daro.yaml은 고객이 관리하며,
진단에는 키 값을 출력하지 않습니다. 재실행하면 입력의 변경사항을 반영합니다.

doctor는 파일을 변경하지 않고 입력과 생성 설정의 일치, 키 파일 복사와 iOS 리소스 등록,
기본 빌드 도구 요구사항을 검사합니다. 키 파일과 App Key의 복호화 가능 여부나 서버 등록은
검증하지 않습니다. Flutter 빌드와 `DaroFlutter.initialize()` 실행으로 실제 연동을 확인하세요.


Flutter 앱에서 Daro 광고를 쉽게 통합할 수 있는 SDK입니다.

## Documentation

자세한 연동 가이드 및 API 문서는 아래 링크를 참고하세요.

https://guide.daro.so/ko/before-the-beginning
