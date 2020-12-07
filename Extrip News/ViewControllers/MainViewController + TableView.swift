//
//  MainViewController + TableView.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 04.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit



extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return articles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "article") as! ArticleCell
    cell.bgImageView.image = nil
    cell.bgImageView?.loadFromURL(string: articles[indexPath.row].image)
    cell.dateLabel.text = articles[indexPath.row].date
    cell.descriptionLabel.text = articles[indexPath.row].description
    cell.selectionStyle = .none
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("IMAGE URL = \(articles[indexPath.row].image)")
    selectedLink = articles[indexPath.row].link
    html = articles[indexPath.row].html
    performSegue(withIdentifier: "article", sender: tableView)
  }
}
