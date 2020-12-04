//
//  MainViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 26/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate {
  func toggleRightMenu()
}

final class ArticleCell: UITableViewCell {
  @IBOutlet weak var bgImageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
}


class MainViewController: UIViewController {
  
  @IBOutlet weak var toolBar: UIToolbar!
  
  ///toolBar objects
  var space: UIBarButtonItem!
  var menuButton: UIBarButtonItem!
  var delegate: MainViewControllerDelegate?
  
  //XML Parsing
  
  @IBOutlet weak var tableView: UITableView!
  var url: URL!
  var selectedLink: String!
  var articles: [Article] = [] {
    didSet {
      DispatchQueue.main.async { self.tableView.reloadData() }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = false
    let lastChannel = Channels(from: UserDefaults.standard.string(forKey: UserDefaultsKeys.lastChannel) ?? "")
    url = URL(string: lastChannel.rawValue)
    navigationItem.title = lastChannel.name
    print(url)
    getXML(from: url)
    toolBarConfig()
  }
}

extension MainViewController {
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
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationVC = segue.destination as? WebViewVC, segue.identifier == "article" {
      destinationVC.urlString = selectedLink
    }
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return articles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "article") as! ArticleCell
    cell.bgImageView?.loadFromURL(string: articles[indexPath.row].image)
    cell.dateLabel.text = articles[indexPath.row].date
    cell.descriptionLabel.text = articles[indexPath.row].description
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedLink = articles[indexPath.row].link
    performSegue(withIdentifier: "article", sender: tableView)
  }
  
//  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//    false
//  }
}
