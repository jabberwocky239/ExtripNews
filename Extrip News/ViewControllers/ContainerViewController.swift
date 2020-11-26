//
//  MainViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
  
  enum SlideMenuState {
    case expanded, collapsed
  }
  
  var currentState: SlideMenuState = .collapsed {
    didSet {
      let shouldShowShadow = currentState == .expanded
//      print(shouldShowShadow)
      shadowForMainViewController(shouldShowShadow)
      mainViewController.webView.isUserInteractionEnabled = !shouldShowShadow
    }
  }

  var mainNavigationController: UINavigationController!
  var mainViewController: MainViewController!
  var menuViewController: SidePanelViewController?
  var userInformationViewController: UserInformationViewController?
  var languageViewController: UIViewController?
  
  var mainPanelExpandedOffset: CGFloat {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      return self.mainViewController.view.frame.width * ControlPanel.padSlideMenuWidth
    default:
      return self.mainViewController.view.frame.width * ControlPanel.phoneSlideMenuWidth
    }
  }

  var swipeToTheRight: UISwipeGestureRecognizer!
  var swipeToTheLeft: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMainView()
    setupGestureRecognizer()
    mainNavigationController.view.clipsToBounds = false
    
  }
  
  func setupMainView() {
    mainViewController = UIStoryboard.mainViewController()
    mainViewController.delegate = self
    mainNavigationController = UINavigationController(rootViewController: mainViewController)
    mainNavigationController.isNavigationBarHidden = true
    view.addSubview(mainNavigationController.view)
    addChild(mainNavigationController)
    mainNavigationController.didMove(toParent: self)
  }
  
  //MARK: - Central Panel
  func shadowForMainViewController(_ shouldHaveShadow: Bool) {
    if shouldHaveShadow {
    mainNavigationController.view.layer.shadowOpacity = 0.6
    mainNavigationController.view.layer.shadowOffset = CGSize(width: 5, height: 0)
        } else {
    mainNavigationController.view.layer.shadowOpacity = 0.0
    }
  }
  
  func animateMainPanel(target: CGFloat, completion: ((Bool)->())? = nil) {
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.75,
                   initialSpringVelocity: 0,
                   options: .curveEaseInOut,
                   animations: { self.mainNavigationController.view.frame.origin.x = target},
                   completion: completion)
  }
  
  //MARK: - Right Panel
  func animateRightPanelMenu(shouldExpand: Bool) {
    if shouldExpand {
      currentState = .expanded
      animateMainPanel(target: -mainPanelExpandedOffset)
    } else {
      animateMainPanel(target: 0) {_ in
        self.currentState = .collapsed
        self.menuViewController?.view.removeFromSuperview()
        self.menuViewController = nil
      }
    }
  }
  
  func addChildMenuPanelViewController(_ menuPanelViewController: SidePanelViewController) {
    menuPanelViewController.delegate = self
    view.insertSubview(menuPanelViewController.view, at: 0)
    addChild(menuPanelViewController)
    menuPanelViewController.didMove(toParent: self)
  }
  
  func addRightMenuViewController() {
    guard menuViewController == nil else {return}
    if let viewController = UIStoryboard.rightMenuController() {
      viewController.menu = MenuItem.items()
      addChildMenuPanelViewController(viewController)
      menuViewController = viewController
    }
  }

  //MARK: - User Information Panel
  func addUserInformationViewController() {
    guard userInformationViewController == nil else {return}
    if let viewController = UIStoryboard.userInformationViewController() {
      userInformationViewController = viewController
      viewController.view.layer.borderColor = ControlPanel.userInformationViewBorderColor.cgColor
      viewController.view.layer.borderWidth = ControlPanel.userInformationViewBorderWidth
      viewController.view.layer.cornerRadius = ControlPanel.userInformationViewBorderRadius
      viewController.view.frame = CGRect(x: self.view.frame.maxX - 10,
                                         y: self.view.frame.maxY / 12,
                                         width: self.view.frame.width * 0.8,
                                         height: self.view.frame.height * 0.8)
      viewController.view.layer.shadowOpacity = 0.5
      viewController.view.layer.shadowOffset = CGSize(width: -5, height: 5)
      viewController.delegate = self
      view.insertSubview(viewController.view, at: 2)
      addChild(viewController)
      viewController.didMove(toParent: self)
      UIView.animate(withDuration: 0.8,
                     delay: 0,
                     usingSpringWithDamping: 0.6,
                     initialSpringVelocity: 0,
                     options: .curveEaseIn,
                     animations: {viewController.view.frame.origin.x = self.view.frame.width - viewController.view.frame.width},
                     completion: { _ in
                      self.mainViewController.view.changeUserInteractionAbility()
      })
    }
  }
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if currentState == .expanded {
    toggleRightMenu()
    
    coordinator.animate(alongsideTransition: nil, completion: {_ in
      self.toggleRightMenu()
      
    })
    }
  
    
  
  }
}

//MARK:-  MainViewControllerDelegate
extension ContainerViewController: MainViewControllerDelegate {
  
  func toggleRightMenu() {
    let isCollapsed = (currentState == .collapsed)
    if isCollapsed {
      addRightMenuViewController()
    }
    animateRightPanelMenu(shouldExpand: isCollapsed)
  }
}
//MARK:-  UserInformationViewControllerDelegate
extension ContainerViewController: UserInformationViewControllerDelegate {
  
  func closeUserInformationViewController() {
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.75,
                   initialSpringVelocity: 0,
                   options: .curveEaseInOut,
                   animations: {self.userInformationViewController!.view.frame.origin.x = self.view.frame.maxX},
                   completion: {_ in
                    self.userInformationViewController?.view.removeFromSuperview()
                    self.userInformationViewController = nil
                    self.mainViewController.view.changeUserInteractionAbility()
    })
  }
}
//MARK:-  SidePanelViewControllerDelegate
extension ContainerViewController: SidePanelViewControllerDelegate {
  func loadAeroexpressURL() {
    toggleRightMenu()
    mainViewController.removeObservers()
    mainViewController.registerIsLoadingObserver()
    mainViewController.registerURLObserver()
    mainViewController.webView.config(url: mainViewController.url)
    mainViewController.portal = .aeroexpress
  }
  
  func loadRailwaysURL() {
    toggleRightMenu()
    mainViewController.removeObservers()
    mainViewController.registerURLObserver()
    mainViewController.webView.config(url: mainViewController.getRzdUrl())
    mainViewController.portal = .rzd
  
  }
  
  var sourceViewForActivityController: UIView { return self.mainViewController.view}
  
  func showUserInformationViewController() {
    toggleRightMenu()
    addUserInformationViewController()
  }
}

  //MARK: - Gesture Recognizer
  extension ContainerViewController: UIGestureRecognizerDelegate {
    func setupGestureRecognizer() {
      swipeToTheLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
      swipeToTheRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
      swipeToTheLeft.direction = .left
      swipeToTheRight.direction = .right
      mainNavigationController.view.addGestureRecognizer(swipeToTheLeft)
      mainNavigationController.view.addGestureRecognizer(swipeToTheRight)
      swipeToTheRight.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }

    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
      switch sender.direction {
      case .left:
        if currentState == .collapsed {toggleRightMenu()}
      case .right:
        if currentState == .expanded {toggleRightMenu()}
      default:
        break
      }
  }
}
//MARK: - Extension to disavle statusBar color change in iOS 13
extension UINavigationController {
  override open var preferredStatusBarStyle: UIStatusBarStyle {
    guard #available(iOS 13, *) else {
      return .default
    }
    return .lightContent
  }
}
