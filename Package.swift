// swift-tools-version:5.7
//
// 통합 SDK 의 SPM 배포 매니페스트 초안. 아직 발행되지 않았다 — Distribution/README.md 참조.
//
// binaryTarget 의 url/checksum 은 릴리스 자동화가 채운다 (레거시 release.yml 이
// Package.swift 를 그렇게 갱신한다). 아래 값은 자리표시자이므로 이대로는 resolve 되지 않는다.
//
// 어댑터 세트는 SDK/DaroSDK/LocalSPM/Package.swift 와 같은 벌이다 — D5 게이트가
// 판정하는 대상이 그쪽이라, 갈라지면 판정을 통과한 것과 발행되는 것이 달라진다.
//
// 제품 이름은 레거시와 같게 두었다. SPM 소비자는 어차피 레포 URL 을 고쳐야 하는데
// (DARO-960 미결 #2), 제품 이름까지 바꾸면 고칠 곳이 둘이 된다. pod 이름이 바뀐 것과
// 별개다 — 그쪽은 trunk 전역 이름 공간 때문에 강제된 것이고 SPM 에는 그런 제약이 없다.

import PackageDescription

let package = Package(
    name: "DaroIntegrated",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DaroAds", targets: ["DaroAds"]),
        .library(name: "DaroObjCBridgeAds", targets: ["DaroObjCBridgeAds"]),
    ],
    dependencies: [
        .package(url: "https://github.com/delightroom/daro-rtb-ios-admob-adapter.git", exact: "2.0.6-rc.9"),
        .package(url: "https://github.com/delightroom/daro-rtb-ios-max-adapter.git", exact: "2.0.6-rc.9"),
        .package(url: "https://github.com/vervegroup/hybid-ios-spm-sdk.git", exact: "3.7.1"),
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            exact: "13.0.0"
        ),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-meta.git",            exact: "6.21.2"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-pangle.git",          exact: "7.9.600"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-inmobi.git",          exact: "11.1.101"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-dtexchange.git",      exact: "8.4.401"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-applovin.git",        exact: "13.6.0"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-ironsource.git",      exact: "9.3.1"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-liftoffmonetize.git", exact: "7.7.0"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-mintegral.git",       exact: "8.0.700"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-moloco.git",          exact: "4.5.0"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-line.git",            exact: "3.0.1"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-unity.git",           exact: "4.16.601"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-pubmatic.git",        exact: "4.12.0"),
    ],
    targets: [
        .binaryTarget(
            name: "Daro",
            url: "https://github.com/delightroom/daro-ios-sdk/releases/download/v2.0.3-rc.5/Daro.xcframework.zip",
            checksum: "3f810f08bac0f4192ce4dc1188a8d97bc4dca52711118de363183a253234baaa"
        ),
        .binaryTarget(
            name: "DaroObjCBridge",
            url: "https://github.com/delightroom/daro-ios-sdk/releases/download/v2.0.3-rc.5/DaroObjCBridge.xcframework.zip",
            checksum: "febc204292c4c1090b3a1e36ffb5d28afe24253f6074330666f4886fdb987de0"
        ),

        // MAX 어댑터는 AppLovin 이 만든 SPM 패키지를 거치지 않고 배포 zip 을 직접 문다.
        // 그 패키지들(AppLovin-MAX-Swift-Package-*)은 2026-06 신설이라 우리가 확정한
        // 버전의 태그가 없다 — 없는 것은 태그이고 zip 은 CDN 에 그대로 있다.
        // 어차피 그 패키지들이 하는 일도 같은 zip 을 가리키는 binaryTarget 선언 하나다.
        //
        // 공유 네트워크 SDK는 AdMob 어댑터가 이미 제공하므로 중복 선언하지 않는다.
        // MAX 전용 Verve는 예외다. HyBid 공식 패키지가 SDK와 ATOM/OM SDK를 제공한다.
        .binaryTarget(
            name: "AppLovinMediationVerveAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/verve-adapter/AppLovinMediationVerveAdapter-3.7.1.0.zip",
            checksum: "56cf5945bc531bbcfe33122f025d3ee931c8cbddfda4757024688e331bd4b18d"
        ),
        .binaryTarget(
            name: "AppLovinMediationInMobiAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/inmobi-adapter/AppLovinMediationInMobiAdapter-11.1.1.0.zip",
            checksum: "0623531b55693e69d1c0e6e6384a8adb65feec3fb5d42f42b514b8994a1f47af"
        ),
        .binaryTarget(
            name: "AppLovinMediationGoogleAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/google-adapter/AppLovinMediationGoogleAdapter-13.0.0.0.zip",
            checksum: "86fa6d7e2df15f82e3658d87c899968751153ca5c33665fbc19bf6191e7c1df2"
        ),
        .binaryTarget(
            name: "AppLovinMediationFacebookAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/facebook-adapter/AppLovinMediationFacebookAdapter-6.21.0.0.zip",
            checksum: "0eded3a5e8a05cf803306316f72db4e6d7d2c64d71b5c2d028922ef3c1d5a068"
        ),
        .binaryTarget(
            name: "AppLovinMediationByteDanceAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/bytedance-adapter/AppLovinMediationByteDanceAdapter-7.9.0.6.0.zip",
            checksum: "8db071029932d62517fca3f76506423c5f641b2073f645e8d21d59c7a42761ca"
        ),
        .binaryTarget(
            name: "AppLovinMediationFyberAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/fyber-adapter/AppLovinMediationFyberAdapter-8.4.4.0.zip",
            checksum: "a9afd8c6079f3ad6fb2fbf35370058b65624f13f0eb88a0610ed79c8380c9d07"
        ),
        .binaryTarget(
            name: "AppLovinMediationIronSourceAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/ironsource-adapter/AppLovinMediationIronSourceAdapter-9.3.0.0.0.zip",
            checksum: "5a8f8b1e1ab7e23fb205cf4c52d66cba2e2f84a17e4e8d53ee53835ffa961cdb"
        ),
        .binaryTarget(
            name: "AppLovinMediationVungleAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/vungle-adapter/AppLovinMediationVungleAdapter-7.7.0.0.zip",
            checksum: "099a3e3560204c695e015b6300a622a9c7be9439b0ad898bbb8cca86c4501aba"
        ),
        .binaryTarget(
            name: "AppLovinMediationMintegralAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/mintegral-adapter/AppLovinMediationMintegralAdapter-8.0.7.0.0.zip",
            checksum: "cae4259573ece2c9bfa58c82f030216d3cea70252da8376fdb18b118b144613d"
        ),
        .binaryTarget(
            name: "AppLovinMediationMolocoAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/moloco-adapter/AppLovinMediationMolocoAdapter-4.5.0.0.zip",
            checksum: "f760b16356a4f26774f0985bf8997e93643ceae186b59dfb777c7596a234684d"
        ),
        .binaryTarget(
            name: "AppLovinMediationLineAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/line-adapter/AppLovinMediationLineAdapter-3.0.0.0.zip",
            checksum: "bcfc42eb3ee07a2443e913397d3ce5ab48fa0e7da15e00d9a03a6d90b1653693"
        ),
        .binaryTarget(
            name: "AppLovinMediationUnityAdsAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/unityads-adapter/AppLovinMediationUnityAdsAdapter-4.16.6.0.zip",
            checksum: "23b507d047e8a254b82552bebc335e5902f8508c21a659b6e36aa5d3f3f9d775"
        ),
        .binaryTarget(
            name: "AppLovinMediationPubMaticAdapter",
            url: "https://artifacts.applovin.com/ios/com/applovin/mediation/pubmatic-adapter/AppLovinMediationPubMaticAdapter-4.12.0.0.zip",
            checksum: "9bcb9c5f17cf2363c9dad37983d262ffdc86f9b75485bf9ebafb4bf9c2086ac8"
        ),
        .target(
            name: "DaroAds",
            dependencies: [
                "Daro",
                .product(name: "DaroBidAdMobAdapter", package: "daro-rtb-ios-admob-adapter"),
                .product(name: "DaroBidMaxAdapter", package: "daro-rtb-ios-max-adapter"),
                .product(name: "GoogleMobileAds",              package: "swift-package-manager-google-mobile-ads"),
                .product(name: "MetaAdapterTarget",            package: "googleads-mobile-ios-mediation-meta"),
                .product(name: "PangleAdapterTarget",          package: "googleads-mobile-ios-mediation-pangle"),
                .product(name: "InMobiAdapterTarget",          package: "googleads-mobile-ios-mediation-inmobi"),
                .product(name: "DTExchangeAdapterTarget",      package: "googleads-mobile-ios-mediation-dtexchange"),
                .product(name: "AppLovinAdapterTarget",        package: "googleads-mobile-ios-mediation-applovin"),
                .product(name: "IronSourceAdapterTarget",      package: "googleads-mobile-ios-mediation-ironsource"),
                .product(name: "LiftoffMonetizeAdapterTarget", package: "googleads-mobile-ios-mediation-liftoffmonetize"),
                .product(name: "MintegralAdapterTarget",       package: "googleads-mobile-ios-mediation-mintegral"),
                .product(name: "MolocoAdapterTarget",          package: "googleads-mobile-ios-mediation-moloco"),
                .product(name: "LineAdapterTarget",            package: "googleads-mobile-ios-mediation-line"),
                .product(name: "UnityAdapterTarget",           package: "googleads-mobile-ios-mediation-unity"),
                .product(name: "PubMaticAdapterTarget",        package: "googleads-mobile-ios-mediation-pubmatic"),
                "AppLovinMediationInMobiAdapter",
                "AppLovinMediationGoogleAdapter",
                "AppLovinMediationFacebookAdapter",
                "AppLovinMediationByteDanceAdapter",
                "AppLovinMediationFyberAdapter",
                "AppLovinMediationIronSourceAdapter",
                "AppLovinMediationVungleAdapter",
                "AppLovinMediationMintegralAdapter",
                "AppLovinMediationMolocoAdapter",
                "AppLovinMediationLineAdapter",
                "AppLovinMediationUnityAdsAdapter",
                "AppLovinMediationPubMaticAdapter",
                "AppLovinMediationVerveAdapter",
                .product(name: "HyBid", package: "hybid-ios-spm-sdk"),
            ],
            path: "SPM/DaroAds"
        ),
        .target(
            name: "DaroObjCBridgeAds",
            dependencies: [
                "DaroObjCBridge",
                .product(name: "DaroBidAdMobAdapter", package: "daro-rtb-ios-admob-adapter"),
                .product(name: "DaroBidMaxAdapter", package: "daro-rtb-ios-max-adapter"),
                .product(name: "GoogleMobileAds",              package: "swift-package-manager-google-mobile-ads"),
                .product(name: "MetaAdapterTarget",            package: "googleads-mobile-ios-mediation-meta"),
                .product(name: "PangleAdapterTarget",          package: "googleads-mobile-ios-mediation-pangle"),
                .product(name: "InMobiAdapterTarget",          package: "googleads-mobile-ios-mediation-inmobi"),
                .product(name: "DTExchangeAdapterTarget",      package: "googleads-mobile-ios-mediation-dtexchange"),
                .product(name: "AppLovinAdapterTarget",        package: "googleads-mobile-ios-mediation-applovin"),
                .product(name: "IronSourceAdapterTarget",      package: "googleads-mobile-ios-mediation-ironsource"),
                .product(name: "LiftoffMonetizeAdapterTarget", package: "googleads-mobile-ios-mediation-liftoffmonetize"),
                .product(name: "MintegralAdapterTarget",       package: "googleads-mobile-ios-mediation-mintegral"),
                .product(name: "MolocoAdapterTarget",          package: "googleads-mobile-ios-mediation-moloco"),
                .product(name: "LineAdapterTarget",            package: "googleads-mobile-ios-mediation-line"),
                .product(name: "UnityAdapterTarget",           package: "googleads-mobile-ios-mediation-unity"),
                .product(name: "PubMaticAdapterTarget",        package: "googleads-mobile-ios-mediation-pubmatic"),
                "AppLovinMediationInMobiAdapter",
                "AppLovinMediationGoogleAdapter",
                "AppLovinMediationFacebookAdapter",
                "AppLovinMediationByteDanceAdapter",
                "AppLovinMediationFyberAdapter",
                "AppLovinMediationIronSourceAdapter",
                "AppLovinMediationVungleAdapter",
                "AppLovinMediationMintegralAdapter",
                "AppLovinMediationMolocoAdapter",
                "AppLovinMediationLineAdapter",
                "AppLovinMediationUnityAdsAdapter",
                "AppLovinMediationPubMaticAdapter",
                "AppLovinMediationVerveAdapter",
                .product(name: "HyBid", package: "hybid-ios-spm-sdk"),
            ],
            path: "SPM/DaroObjCBridgeAds"
        ),

    ]
)
