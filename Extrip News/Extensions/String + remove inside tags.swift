//
//  String + remove inside tags.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 05.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import Foundation
extension String {
  func slice(from: String, to: String) -> String? {
    return (range(of: from)?.upperBound).flatMap { substringFrom in
      (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
        String(self[substringFrom..<substringTo])
      }
    }
  }
  
  func removeBetween(_ from: String, _ to: String) -> String? {
    return self.replacingOccurrences(of: from + ((slice(from: from, to: to)) ?? "") + to, with: "")
  }
}
