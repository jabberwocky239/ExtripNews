//
//  MenuItem.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 29/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit
struct MenuItem {
  
  let title: String
  let image: UIImage?
  let type: Int
  
  init(title: String, image: UIImage?, type: Int) {
    self.title = title
    self.image = image
    self.type = type
    
  }
  
  static func items() -> [MenuItem] {
    return [
      //Channels
 
      //Extrip
    MenuItem(title: NSLocalizedString("Our apps", comment: ""), image: nil, type: 1),
    MenuItem(title: NSLocalizedString("Share", comment: ""), image: nil, type: 1),
    MenuItem(title: NSLocalizedString("Rate this app", comment: ""), image: nil, type: 1),
    MenuItem(title: NSLocalizedString("User information", comment: ""), image: nil, type: 1)].reversed()
  }
  
}
