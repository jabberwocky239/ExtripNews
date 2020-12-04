//
//  WebViewVC.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 04.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
  
  @IBOutlet weak var webView: WKWebView!
  var urlString: String!
  var html: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
   print("WEBVIEWVC LOADED")
    guard let url = URL(string: urlString) else {return}
    print(url)
//    webView.load(URLRequest(url: url))
    webView.scrollView.bounces = false
    webView.loadHTMLString(html, baseURL: nil)
    print(html)
  }
}
