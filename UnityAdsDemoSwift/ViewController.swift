//
//  ViewController.swift
//  UnityAdsDemoSwift
//
//  Created by CallieZhu on 2021/1/25.
//

import UIKit
import UnityAds
import AdSupport

private let kDefaultGameId = "14850"
private let kGameIdKey = "adsExampleAppGameId"
private var kMediationOrdinal = 1

class ViewController: UIViewController, UnityAdsInitializationDelegate, UnityAdsDelegate, UADSBannerViewDelegate {
    
    // view outlets
    @IBOutlet weak var interstitialButton: UIButton!
    @IBOutlet weak var incentivizedButton: UIButton!
    @IBOutlet weak var initializeButton: UIButton!
    @IBOutlet weak var bannerButton: UIButton!
    @IBOutlet weak var gameIdTextField: UITextField!
    @IBOutlet weak var testModeButton: UIButton!
   
    private var bannerView: UADSBannerView?
    private var defaultGameId: String?
    private var testMode = false
    private var interstitialPlacementId: String?
    private var incentivizedPlacementId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if !UnityAds.isReady() {
            let defaults = UserDefaults.standard
            if defaults.string(forKey: kGameIdKey) != nil {
                gameIdTextField.text = defaults.string(forKey: kGameIdKey)
            } else {
                gameIdTextField.text = kDefaultGameId
            }
        }

        interstitialButton.isEnabled = false
        interstitialButton.backgroundColor = UIColor(red: 0.13, green: 0.17, blue: 0.22, alpha: 0.8)
        incentivizedButton.isEnabled = false
        incentivizedButton.backgroundColor = UIColor(red: 0.13, green: 0.17, blue: 0.22, alpha: 0.8)
        initializeButton.isEnabled = true
        bannerButton.isEnabled = false
        bannerButton.backgroundColor = UIColor(red: 0.13, green: 0.17, blue: 0.22, alpha: 0.8)
        testMode = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneEditingGameId(_ sender: Any) {
        gameIdTextField.resignFirstResponder()
    }
    
    @IBAction func toggleTestMode(_ sender: Any) {
        testMode = !testMode
        testModeButton.setTitle(testMode ? "ON" : "OFF", for: .normal)
    }

    @IBAction func incentivizedButtonTapped(_ sender: Any) {
        if UnityAds.isReady(incentivizedPlacementId ?? "rewardedVideo") {
            incentivizedButton.isEnabled = false
            let playerMetaData = UADSPlayerMetaData()
            playerMetaData.setServerId("rikshot")
            playerMetaData.commit()

            let mediationMetaData = UADSMediationMetaData()
            mediationMetaData.setOrdinal(Int32(kMediationOrdinal))
            kMediationOrdinal += 1
            mediationMetaData.commit()

            UnityAds.show(self, placementId: incentivizedPlacementId ?? "rewardedVideo")
        }
    }
    
    @IBAction func interstitialButtonTapped(_ sender: Any) {
        if UnityAds.isReady(interstitialPlacementId ?? "video") {
            interstitialButton.isEnabled = false
            let playerMetaData = UADSPlayerMetaData()
            playerMetaData.setServerId("rikshot")
            playerMetaData.commit()
            
            let mediationMetaData = UADSMediationMetaData()
            mediationMetaData.setOrdinal(Int32(kMediationOrdinal))
            kMediationOrdinal += 1
            mediationMetaData.commit()

            UnityAds.show(self, placementId: interstitialPlacementId ?? "video")
        }
    }

    @IBAction func bannerButtonTapped(_ sender: Any) {
//        if bannerButton.titleLabel?.text == "Hide Banner" {
//            // close banner
////            UnityAdsBanner.destroy()
//            bannerView?.removeFromSuperview()
//            bannerView = nil
//            bannerButton.setTitle("Show Banner", for: .normal)
//        } else {
            // load banner
//            bannerButton.setTitle("Hide Banner", for: .normal)

        let bannerView = UADSBannerView(placementId: "bannerads", size: CGSize(width: 320, height: 50))
        bannerView.delegate = self
        bannerView.load()
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
        [
            NSLayoutConstraint(
                item: bannerView as UIView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: bannerView as UIView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0)
        ])
    }
    
    @IBAction func initializeButtonTapped(_ sender: Any) {
        let gameId = (gameIdTextField.text != "") ? gameIdTextField.text : kDefaultGameId

        let defaults = UserDefaults.standard
        defaults.set(gameId, forKey: kGameIdKey)

        // mediation
        let mediationMetaData = UADSMediationMetaData()
        mediationMetaData.setName("mediationPartner")
        mediationMetaData.setVersion("v12345")
        mediationMetaData.commit()

        let debugMetaData = UADSMetaData()
        debugMetaData.set("test.debugOverlayEnabled", value: NSNumber(value: true))
        debugMetaData.commit()

        initializeButton.isEnabled = false
        initializeButton.backgroundColor = UIColor(red: 0.13, green: 0.17, blue: 0.22, alpha: 0.8)
        gameIdTextField.isEnabled = false
        testModeButton.isEnabled = false
        bannerButton.isEnabled = true
        bannerButton.backgroundColor = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0)
        UnityAds.setDebugMode(true)
        UnityAds.add(self)
        UnityAds.initialize(gameId!, testMode: testMode, initializationDelegate: self)
    }
    
    func initializationComplete() {
        print("UnityAds initializationComplete")
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        print("UnityAds initializationFailed: \(error) - \(message)")
        let alert = UIAlertController(title: "UnityAds Initialization Error", message: "\(error) - \(message)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func unityAdsReady(_ placementId: String) {
        print("UADS Ready")

        if (placementId == "video") || (placementId == "defaultZone") || (placementId == "defaultVideoAndPictureZone") {
            interstitialPlacementId = placementId
            interstitialButton.isEnabled = true
            interstitialButton.backgroundColor = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0)
        }
        if (placementId == "rewardedVideo") || (placementId == "rewardedVideoZone") || (placementId == "incentivizedZone") {
            incentivizedPlacementId = placementId
            incentivizedButton.isEnabled = true
            incentivizedButton.backgroundColor = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0)
        }
    }
    
    func unityAdsDidStart(_ placementId: String) {
        print("UADS Start")
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        var stateString = "UNKNOWN"
        switch state {
        case .error:
                stateString = "ERROR"
        case .skipped:
                stateString = "SKIPPED"
        case .completed:
                stateString = "COMPLETED"
            default:
                break
        }
        print("UnityAds FINISH: \(stateString) - \(placementId)")
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
        print("UnityAds ERROR: \(error) - \(message)")
        if floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0 {
            let alert = UIAlertController(title: "UnityAds Error", message: "\(error) - \(message)", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            })
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    func bannerViewDidLoad(_ bannerView: UADSBannerView) {
        // Called when the banner view object finishes loading an ad.
        print("Banner loaded for Placement: \(bannerView.placementId)")
        self.view.addSubview(bannerView)
        
    }

    func bannerViewDidClick(_ bannerView: UADSBannerView) {
        // Called when the banner is clicked.
        print("Banner was clicked for Placement: \(bannerView.placementId)")
    }

    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView) {
        // Called when the banner links out of the application.
    }

    func bannerViewDidError(_ bannerView: UADSBannerView, error: UADSBannerError) {
        // Called when an error occurs showing the banner view object.
        print("Banner encountered an error for Placement: \(bannerView.placementId) with error message \(error.description)");
        // Note that the UADSBannerError can indicate no fill (see API documentation).
    }
}

