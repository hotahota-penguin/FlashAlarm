import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        // banner.adUnitID = "ca-app-pub-4847616539890648/5886682658"
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        // Root view controller is required for the banner to be displayed
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
}
