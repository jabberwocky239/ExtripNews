//
//  Languages.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 04/10/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import Foundation

public struct Languages {
  
  static func devicePreferredLanguages() -> [String] {
    return Locale.preferredLanguages.map {String($0.prefix(2))}
  }
  
  static func findLanguage() -> String {
    let devicePreferredLanguages = Languages.devicePreferredLanguages()
    var mainLanguage = "en"
    for language in devicePreferredLanguages {
      if appleLanguageCodes.contains(language) {
        mainLanguage = language
        break
      }
    }
    return mainLanguage
  }
  
  static let appleLanguageCodes = [
    "en",
    "ru",
    "de",
    "zh",
  ]
  
  static let urls = [
    "https://www.aeroexpress.app/app.html#/en",
    "https://www.aeroexpress.app/app.html#/",
    "https://www.aeroexpress.app/app.html#/de",
    "https://www.aeroexpress.app/app.html#/zh",
      ]
  
  static let aeSheduleURL = "https://www.aeroexpress.app/ae/index.html"
}
