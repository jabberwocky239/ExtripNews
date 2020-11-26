//
//  MainViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit
import WebKit

protocol MainViewControllerDelegate {
  func toggleRightMenu()
}

class MainViewController: UIViewController {
  
  @IBOutlet weak var toolBar: UIToolbar!
  
  
  ///toolBar objects
  var space: UIBarButtonItem!
  var menuButton: UIBarButtonItem!
  var delegate: MainViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    toolBarConfig()
  }
  
  //MARK:- ToolBar config
  func toolBarConfig() {
    toolBar.backgroundColor = ControlPanel.toolBarBackgroundColor
    space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                            target: nil,
                            action: nil)
    
    
    
    menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(barButtonMenuTapped))
    
    menuButton?.tintColor = .darkGray
    toolBar.items = [space, menuButton]
    
  }
  //MARK:- TOOLBAR BUTTONS ACTIONS
  @objc func shareButtonTapped() {
    let activityViewController = UIActivityViewController(activityItems: [ControlPanel.appStoreUrl],
                                                          applicationActivities: nil)
    if UIDevice.current.userInterfaceIdiom == .pad {
      activityViewController.popoverPresentationController?.sourceView = self.view
      activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0,
                                                                                y: 30,
                                                                                width: view.frame.width,
                                                                                height: view.frame.height)
    }
    self.present(activityViewController, animated: true)
  }
  
  @objc func barButtonMenuTapped() {
    delegate?.toggleRightMenu()
    // Prompt for review (10 times needed)
    ReviewRequest.shared.promptReview()
  }
}

