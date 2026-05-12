// swift-tools-version:5.7
// Package.swift for Daro iOS SDK

import PackageDescription

let package = Package(
    name: "Daro",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DaroAds", targets: ["DaroAds"]),
        .library(name: "DaroObjCBridgeAds", targets: ["DaroObjCBridgeAds"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            exact: "13.0.0"
        ),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-meta.git",            exact: "6.21.2"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-pangle.git",          exact: "7.9.600"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-inmobi.git",          exact: "11.1.101"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-dtexchange.git",      exact: "8.4.401"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-chartboost.git",      exact: "9.11.3"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-applovin.git",        exact: "13.6.0"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-ironsource.git",      exact: "9.3.1"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-liftoffmonetize.git", exact: "7.7.0"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-mintegral.git",       exact: "8.0.700"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-moloco.git",          exact: "4.5.000"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-line.git",            exact: "3.0.1"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-unity.git",           exact: "4.16.601"),
        .package(url: "https://github.com/googleads/googleads-mobile-ios-mediation-pubmatic.git",        exact: "4.12.0"),
    ],
    targets: [
        .binaryTarget(
            name: "Daro",
            url: "https://github.com/delightroom/daro-ios-sdk/releases/download/1.1.57/Daro.xcframework.zip",
            checksum: "ff2470428c99713bb8642a6f65a83dbcbfefe7d25fd0a40e4672a8a43eccecc8"
        ),
        .binaryTarget(
            name: "DaroObjCBridge",
            url: "https://github.com/delightroom/daro-ios-sdk/releases/download/1.1.57/DaroObjCBridge.xcframework.zip",
            checksum: "9f74a19db1ee6b2d5895a4a45344fa7ffa94f8ccbf17cc96d2ad125ed2eda560"
        ),
        .target(
            name: "DaroAds",
            dependencies: [
                "Daro",
                .product(name: "GoogleMobileAds",              package: "swift-package-manager-google-mobile-ads"),
                .product(name: "MetaAdapterTarget",            package: "googleads-mobile-ios-mediation-meta"),
                .product(name: "PangleAdapterTarget",          package: "googleads-mobile-ios-mediation-pangle"),
                .product(name: "InMobiAdapterTarget",          package: "googleads-mobile-ios-mediation-inmobi"),
                .product(name: "DTExchangeAdapterTarget",      package: "googleads-mobile-ios-mediation-dtexchange"),
                .product(name: "ChartboostAdapterTarget",      package: "googleads-mobile-ios-mediation-chartboost"),
                .product(name: "AppLovinAdapterTarget",        package: "googleads-mobile-ios-mediation-applovin"),
                .product(name: "IronSourceAdapterTarget",      package: "googleads-mobile-ios-mediation-ironsource"),
                .product(name: "LiftoffMonetizeAdapterTarget", package: "googleads-mobile-ios-mediation-liftoffmonetize"),
                .product(name: "MintegralAdapterTarget",       package: "googleads-mobile-ios-mediation-mintegral"),
                .product(name: "MolocoAdapterTarget",          package: "googleads-mobile-ios-mediation-moloco"),
                .product(name: "LineAdapterTarget",            package: "googleads-mobile-ios-mediation-line"),
                .product(name: "UnityAdapterTarget",           package: "googleads-mobile-ios-mediation-unity"),
                .product(name: "PubMaticAdapterTarget",        package: "googleads-mobile-ios-mediation-pubmatic"),
            ],
            path: "SPM/DaroAds"
        ),
        .target(
            name: "DaroObjCBridgeAds",
            dependencies: [
                "DaroObjCBridge",
                .product(name: "GoogleMobileAds",              package: "swift-package-manager-google-mobile-ads"),
                .product(name: "MetaAdapterTarget",            package: "googleads-mobile-ios-mediation-meta"),
                .product(name: "PangleAdapterTarget",          package: "googleads-mobile-ios-mediation-pangle"),
                .product(name: "InMobiAdapterTarget",          package: "googleads-mobile-ios-mediation-inmobi"),
                .product(name: "DTExchangeAdapterTarget",      package: "googleads-mobile-ios-mediation-dtexchange"),
                .product(name: "ChartboostAdapterTarget",      package: "googleads-mobile-ios-mediation-chartboost"),
                .product(name: "AppLovinAdapterTarget",        package: "googleads-mobile-ios-mediation-applovin"),
                .product(name: "IronSourceAdapterTarget",      package: "googleads-mobile-ios-mediation-ironsource"),
                .product(name: "LiftoffMonetizeAdapterTarget", package: "googleads-mobile-ios-mediation-liftoffmonetize"),
                .product(name: "MintegralAdapterTarget",       package: "googleads-mobile-ios-mediation-mintegral"),
                .product(name: "MolocoAdapterTarget",          package: "googleads-mobile-ios-mediation-moloco"),
                .product(name: "LineAdapterTarget",            package: "googleads-mobile-ios-mediation-line"),
                .product(name: "UnityAdapterTarget",           package: "googleads-mobile-ios-mediation-unity"),
                .product(name: "PubMaticAdapterTarget",        package: "googleads-mobile-ios-mediation-pubmatic"),
            ],
            path: "SPM/DaroObjCBridgeAds"
        ),
    ]
)
