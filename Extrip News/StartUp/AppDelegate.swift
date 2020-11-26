//
//  AppDelegate.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)
    
    let initiateViewController = ContainerViewController()
    window!.rootViewController = initiateViewController
    window!.makeKeyAndVisible()
    return true
  }
}

