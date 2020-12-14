//
//  MainViewController + network.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 02.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit

extension MainViewController {
  
  func getXML(from url: URL) {
    articles = []
    ActivityIndicator.show("")
    let completion: (Result<Data, Error>) -> Void = { [weak self] result in
      guard let self = self else {return}
      switch result {
      case .success(let data):
        if let articles = [Article].init(data, channel: self.channel) {
          self.articles = articles
        }
      case .failure(let error):
        print(error)
      }
      ActivityIndicator.dismiss()
    }
    URLSession.request(url: url,
                       parameters: [:],
                       completion: completion)
    
  }
}

extension MainViewController {
  func change(channel: Channels) {
    UserDefaults.standard.set(channel.name, forKey: UserDefaultsKeys.lastChannel)
    self.channel = channel
  }
}

struct PublicationDate {
  static func short(from longString: String) -> String {
    let df = DateFormatter()
    df.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
    return DateFormatter.localizedString(from: df.date(from: longString) ?? Date(), dateStyle: .medium, timeStyle: .none)
  }
}
