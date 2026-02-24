import Flutter

class DaroAdInstanceManager {
    static let shared = DaroAdInstanceManager()

    private var ads: [Int: FlutterPlatformView] = [:]

    func store(_ ad: FlutterPlatformView, forId adId: Int) {
        ads[adId] = ad
    }

    func get(forId adId: Int) -> FlutterPlatformView? {
        return ads[adId]
    }

    func remove(forId adId: Int) {
        ads.removeValue(forKey: adId)
    }
}
