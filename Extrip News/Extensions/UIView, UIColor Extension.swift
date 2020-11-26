//
//  UIView Extension.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 04/10/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

extension UIView {
  
  func changeUserInteractionAbility() {
    let isEnabled = self.isUserInteractionEnabled
    self.isUserInteractionEnabled = !isEnabled
  }
}

extension UIColor {
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )

        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }

        return color
    }
}
