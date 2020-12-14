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
  func choose(channel: Channels)
  func closeSideMenu()
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
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return menu.filter{$0.type == 1}.count
    case 1: return menu.filter{$0.type == 2}.count
    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let titleText: String = {
      switch section {
      case 0: return "ПРИЛОЖЕНИЯ"
      case 1: return "КАНАЛЫ"
      default: return ""
      }
    }()
    let rect = CGRect(x: 0, y: 0, width: self.view.frame.width * ControlPanel.menuSlideWidth, height: 44)
    let view = UIView(frame: rect)
    let label = UILabel(frame: rect)
    label.text = titleText
    label.textAlignment = .center
    label.backgroundColor = UIColor.white
    view.addSubview(label)
    view.transform = CGAffineTransform (scaleX: 1,y: -1)
    return view
  }
  

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let view = UIView()
    view.backgroundColor = ControlPanel.selectedCellColor
    cell.selectedBackgroundView = view
    cell.backgroundColor = ControlPanel.sideMenuCellsBackgroundColor
   
    cell.textLabel?.text = nil
    cell.textLabel!.text = menu.filter{$0.type == (indexPath.section + 1)}[indexPath.row].title
    cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
    cell.selectionStyle = .none
    return cell
  }
}

//MARK: - UITableViewDelegate methods

extension SidePanelViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath {
    case [0,0]: rate()
    case [0,1]: share()
    case [0,2]: showExtripApps()
    default:
      switch indexPath.row {
      case 0: delegate?.choose(channel: Channels.search)
      case 1: delegate?.choose(channel: Channels.rent)
      case 2: delegate?.choose(channel: Channels.railroad)
      case 3: delegate?.choose(channel: Channels.insuranse)
      case 4: delegate?.choose(channel: Channels.hotels)
      case 5: delegate?.choose(channel: Channels.ferry)
      case 6: delegate?.choose(channel: Channels.avia)
      case 7: delegate?.choose(channel: Channels.aeroexpress)
      default: delegate?.choose(channel: Channels.railroad)
      }
      delegate?.closeSideMenu()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
      false
    }
    
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
