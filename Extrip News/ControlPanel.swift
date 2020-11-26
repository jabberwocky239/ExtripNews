//
//  ControlPanel.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 29/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

// Change any interface details in this Control Panel

struct ControlPanel {

  //MARK: AppStore URL
  static let appStoreUrl = "https://itunes.apple.com/us/app/aeroexpress/id1477253005?ls=1&mt=8"
  
  //MARK: - SideMenu Buttons
  static let sectionHeaderHeight: CGFloat = 45
  
  //MARK: - Some approproate colors
  //MARK:- Ferry
  private static let ferryHeaderBlueColor: UIColor = #colorLiteral(red: 0.1015920416, green: 0.3366616964, blue: 0.5192688704, alpha: 1)
  private static let ferryButtonGreenColor: UIColor = #colorLiteral(red: 0.2662225962, green: 0.6301333308, blue: 0.2448786795, alpha: 1)
  private static let ferryDiscountBadgeYellowColor = #colorLiteral(red: 0.983158052, green: 0.8429540992, blue: 0.003475040197, alpha: 1)
  private static let ferryDiscountChooseCurrencyButtonGoldenColor = #colorLiteral(red: 0.9758846164, green: 0.7250579, blue: 0.07519575208, alpha: 1)
  private static let ferryBorderPaleYellow = #colorLiteral(red: 0.9885168672, green: 0.8982757926, blue: 0.5790961385, alpha: 1)
  //MARK:- Aeroexpress
  private static let aeroexpressDarkBlueColor = #colorLiteral(red: 0.1282478571, green: 0.1578295827, blue: 0.2220559716, alpha: 1)
  private static let aeroexpressOrangeColor = #colorLiteral(red: 0.9630091786, green: 0.4191854596, blue: 0.01631666161, alpha: 1)
  
  //MARK:- Toolbar interface
  static let toolBarBackgroundColor: UIColor = .lightGray
  
  //MARK:- Side Menu Interface
  static let sideMenuBackgroundColor: UIColor = ControlPanel.aeroexpressDarkBlueColor
  static let sideMenuCellsBackgroundColor: UIColor = ControlPanel.aeroexpressOrangeColor
  static let selectedCellColor: UIColor = ControlPanel.aeroexpressDarkBlueColor
  
  //MARK: - UserInformation View interface
  static let userInformationViewBorderColor: UIColor = ControlPanel.aeroexpressDarkBlueColor
  static let userInformationViewBorderWidth: CGFloat = 4
  static let userInformationViewBorderRadius: CGFloat = 20
  static let userInformationViewButtonsCornerRadius: CGFloat = 5
  
  static let continueButtonBackgroundColor: UIColor = ControlPanel.aeroexpressOrangeColor
  static let clearButtonBackgroundColor: UIColor = ControlPanel.aeroexpressOrangeColor
  static let segmentedControlBackgroundColor: UIColor = ControlPanel.ferryButtonGreenColor
  
  //MARK: - Slide Menu Width
  
  static let phoneSlideMenuWidth: CGFloat = 0.67
  static let padSlideMenuWidth: CGFloat = 0.33
  
  //MARK: - WebView
  
  static let mainDivColor: UIColor = ControlPanel.ferryButtonGreenColor
  static let mainDivBorderColor: UIColor = ControlPanel.ferryButtonGreenColor

}
