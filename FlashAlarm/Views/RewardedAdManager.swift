import Foundation
import GoogleMobileAds
import UIKit

class RewardedAdManager: NSObject, FullScreenContentDelegate {
    static let shared = RewardedAdManager()
    var rewardedAd: RewardedAd?
    
    // Test Ad Unit ID for Rewarded Ads
    // Replace with your actual Ad Unit ID in production
    let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    override private init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded.")
        }
    }
    
    func showAd(from rootViewController: UIViewController, completion: @escaping () -> Void) {
        if let ad = rewardedAd {
            ad.present(from: rootViewController) {
                let reward = ad.adReward
                print("Reward received with currency: \(reward.type), amount: \(reward.amount)")
                // Reward the user.
                completion()
            }
        } else {
            print("Ad wasn't ready")
            loadAd() // Try to load for next time
            completion()
        }
    }
    
    // MARK: - FullScreenContentDelegate
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad recorded an impression.")
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad recorded a click.")
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Rewarded ad failed to present full screen content with error: \(error.localizedDescription)")
        loadAd()
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad will dismiss full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad did dismiss full screen content.")
        loadAd()
    }
}
