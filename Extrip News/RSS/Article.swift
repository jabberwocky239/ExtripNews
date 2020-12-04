//
//  Article.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 02.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import Foundation

struct Article {
  var description: String
  var link: String
  var date: String
  var image: String
  
//  init?(xml: XML.Accessor) {
//
//    if let linkString = xml.link.text {
//      self.link = URL(string: linkString)
//    }
//  }
  
  static let empty = Article(description: "", link: "", date: "", image: "")
}
