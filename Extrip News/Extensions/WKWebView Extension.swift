//
//  WKWebView Extension.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 04/10/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import WebKit

extension WKWebView {
  
  /// PageType is used to implement various JS depending of page type
  enum PageType {
    case aeroexpress, rzd, other
  }
  
  var currentPageType: PageType {
    get {
      let stringUrl = (self.url?.absoluteString)!
      switch stringUrl {
      case let url where url.contains("aeroexpress"):
        return .aeroexpress
      case let url where url.contains("rzd"):
        return .rzd
      default: return .other
      }
    }
  }
  
  
  func config(url: String) {
    self.scrollView.bounces = false
    self.scrollView.showsVerticalScrollIndicator = false
    self.configuration.suppressesIncrementalRendering = true
    if let url = URL(string: url) {
      self.load(URLRequest(url: url))
    }
  }
  
  func evaluate(script: String) {
    self.evaluateJavaScript(script) {_, error in
      if error != nil {
//        self.evaluate(script: script)
        print(error as Any)
      }
    }
  }
  
  func autoFillUserInformation() {
    print("autofill started")
    let script = ScriptStorage.autofillScriptFor(portal: self.currentPageType)
    self.evaluate(script: script)
  }
  
  func loadFrom(string: String) {
    if let url = URL(string: string) {
      let request = URLRequest(url: url)
      self.load(request)
    }
  }
}
