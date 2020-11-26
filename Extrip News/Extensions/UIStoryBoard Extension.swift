//
//  UIStoryBoard Extension.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 27/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

public extension UIStoryboard {
  static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main)}
  
  static internal func mainViewController() -> MainViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
  }
  
  static internal func rightMenuController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "RightMenuViewController") as? SidePanelViewController
  }

  static internal func userInformationViewController() -> UserInformationViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "UserInformationViewController") as? UserInformationViewController
  }
}
