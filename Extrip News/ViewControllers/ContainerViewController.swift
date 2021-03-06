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
      shadowForMainViewController(shouldShowShadow)
    }
  }

  var mainNavigationController: UINavigationController!
  var mainViewController: MainViewController!
  var menuViewController: SidePanelViewController?
  
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

//MARK:-  SidePanelViewControllerDelegate
extension ContainerViewController: SidePanelViewControllerDelegate {
  func closeSideMenu() {
    toggleRightMenu()
  }
  func choose(channel: Channels) {
    mainViewController.change(channel: channel)
  }
  
  
  var sourceViewForActivityController: UIView { return self.mainViewController.view}
  
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
