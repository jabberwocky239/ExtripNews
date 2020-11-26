//
//  ScriptStorage.swift
//  Hotels
//
//  Created by Maxim Gaysin on 26.10.2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import Foundation
import WebKit

struct ScriptStorage {
  
  ///hides header
  static let mainPageHideHeader = "document.getElementsByClassName('ex-header')[0].hidden = true;"
  
  /// AUTOFILL
  static func autofillScriptFor(portal: WKWebView.PageType) -> String {
    let userInfo: [String: String?] = [
      "name": Storage.userDefaults.string(forKey: "name"),
      "surname": Storage.userDefaults.string(forKey: "surname"),
      "email": Storage.userDefaults.string(forKey: "email"),
      "phone": Storage.userDefaults.string(forKey: "phoneNumber")
    ]
    var script = ""
    
    switch portal {
    case .aeroexpress:
      for (key, value) in userInfo {
        if value != nil {
          switch key {
          case "name":
            script += "document.getElementsByClassName('ex-textinput')[1].;"
            script += "document.getElementsByClassName('ex-textinput')[1].value = '\(userInfo["name"]!!)';"
          case "surname":
            script += "document.getElementsByClassName('ex-textinput')[0].value = '\(userInfo["surname"]!!)';"
          case "email":
            script += "document.getElementsByClassName('ex-textinput')[5].value = '\(userInfo["email"]!!)';"
          case "phone":
            script += "document.getElementsByClassName('ex-textinput')[4].value = '\(userInfo["phone"]!!)';"
          default: break
          }
        }
      }
 
    default:
      return script
    }
    
    return script
  }
  
}
