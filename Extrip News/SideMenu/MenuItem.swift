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
  let type: Int
  
  init(title: String, type: Int) {
    self.title = title
    self.type = type
    
  }
  
  static func items() -> [MenuItem] {
    return [
      //Extrip
      MenuItem(title: NSLocalizedString("Наши приложения", comment: ""), type: 1),
      MenuItem(title: NSLocalizedString("Подлиться", comment: ""), type: 1),
      MenuItem(title: NSLocalizedString("Оцeните приложение", comment: ""), type: 1),
      //Channels
      MenuItem(title: Channels.aeroexpress.name, type: 2),
      MenuItem(title: Channels.avia.name, type: 2),
      MenuItem(title: Channels.ferry.name, type: 2),
      MenuItem(title: Channels.hotels.name, type: 2),
      MenuItem(title: Channels.insuranse.name, type: 2),
      MenuItem(title: Channels.railroad.name, type: 2),
      MenuItem(title: Channels.rent.name, type: 2),
      MenuItem(title: Channels.search.name, type: 2)
    ]
    .reversed()
  }
  
}
