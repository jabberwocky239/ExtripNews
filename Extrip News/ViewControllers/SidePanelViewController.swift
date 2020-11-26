//
//  SidePanelViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit
import StoreKit

protocol SidePanelViewControllerDelegate {
  var sourceViewForActivityController: UIView { get }
}

class SidePanelViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var tableViewWidthConstraint: NSLayoutConstraint!

  var delegate: SidePanelViewControllerDelegate?
  var menu: [MenuItem]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //MARK: CONTROL PANEL PROPERTY
    view.backgroundColor = ControlPanel.sideMenuBackgroundColor
//    tableView.register(MenuCell.self, forCellReuseIdentifier: "cell")
//    view.layoutIfNeeded()
//    tableViewHeightConstraint.constant = CGFloat(self.tableView.contentSize.height) + 5
    tableViewWidthConstraint.constant = {
      //MARK: TODO - move all constants to CONTROLPANEL
      switch UIDevice.current.userInterfaceIdiom {
      case .pad:
        return self.view.frame.width * 0.33
      default:
        return self.view.frame.width * 0.67
      }
    }()
    tableView.bounces = false
    tableView.transform = CGAffineTransform (scaleX: 1,y: -1)
  }
  
}
//MARK: - UITableViewDataSource methods
extension SidePanelViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return menu.count
  }

  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let view = UIView()
    view.backgroundColor = ControlPanel.selectedCellColor
    cell.selectedBackgroundView = view
    cell.backgroundColor = ControlPanel.sideMenuCellsBackgroundColor
   
    cell.textLabel?.text = nil
    cell.textLabel!.text = menu[indexPath.row].title
    cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
    return cell
  }
}

//MARK: - UITableViewDelegate methods

extension SidePanelViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
  }
  fileprivate func showExtripApps() {
    let appsViewController = SKStoreProductViewController()
    appsViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: 1042411223], completionBlock: nil)
    appsViewController.delegate = self
    self.present(appsViewController, animated: true)
  }
  
  fileprivate func share() {
    let activityViewController = UIActivityViewController(activityItems: [ControlPanel.appStoreUrl],
                                                          applicationActivities: nil)
    if UIDevice.current.userInterfaceIdiom == .pad {
      activityViewController.popoverPresentationController?.sourceView = delegate?.sourceViewForActivityController
      activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0,
                                                                                y: view.frame.maxY - 50,
                                                                                width: view.frame.width,
                                                                                height: view.frame.height)
    }
    self.present(activityViewController, animated: true)
  }
  
  fileprivate func rate() {
    // TODO: refresh App ID
    guard let writeReviewURL = URL(string: ControlPanel.appStoreUrl)
      else { fatalError("Expected a valid URL") }
    UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)

  }
}

//MARK: StoreKit ProductViewControllerDelegate
extension SidePanelViewController: SKStoreProductViewControllerDelegate {
  func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    self.dismiss(animated: true, completion: nil)
  }
}
