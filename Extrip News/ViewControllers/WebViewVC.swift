//
//  WebViewVC.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 04.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class WebViewVC: UIViewController, GADAdaptiveBannerVC {
  
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var bannerView: GADBannerView!
  var html: HTML! {
    didSet {
      print("HTML \(String(describing: html.content))")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bannerView.adUnitID = "ca-app-pub-5250587637050130/6447742675"
    bannerView.rootViewController = self
    webView.scrollView.bounces = false
    webView.loadHTMLString(html.content, baseURL: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadBannerAd()
  }
  
  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.loadBannerAd()
    })
  }
}
