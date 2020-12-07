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
    let completion: (Result<Data, Error>) -> Void = { [weak self] result in
      guard let self = self else {return}
      switch result {
      case .success(let data):
        var x = self.channel.fakeItemsNumber
        var items: [XML.Accessor] = []
        let channel = XML.parse(data).rss.channel
        var item: XML.Accessor = channel.item[x]
        while item.pubDate.text != nil {
          items.append(item)
          x += 1
          item = channel.item[x]
        }
        //
        var articles = Array(repeating: Article.empty, count: items.count)
        
        let itemTexts: [String?] = items.map({
          $0["turbo:content"].text?
            .replacingOccurrences(of: "&", with: "")
          
          
        })
        let newItems: [XML.Accessor] = itemTexts.compactMap({
          try? XML.parse("<content>" + ($0 ?? "") + "</content>")
        })
 
        let htmls: [String] = items.compactMap({
          HTMLTags.prefix + ($0["turbo:content"]
                  .text?
                  .removeBetween("<menu>", "</menu>")?
                  .removeBetween("<figure>", "</figure>") ?? "")

            
            + HTMLTags.suffix
        })
        
        newItems.enumerated().forEach({
          articles[$0.offset].description = $0.element.content.header.h1.text?      .replacingOccurrences(of: "quot;", with: "\"")
            .replacingOccurrences(of: "amp;", with: "&")
            .replacingOccurrences(of: "laquo;", with: "\"")
            .replacingOccurrences(of: "laquo;", with: "\"")
            .replacingOccurrences(of: "nbsp;", with: " ")
            .replacingOccurrences(of: "ndash;", with: " - ")
            .replacingOccurrences(of: "#039;", with: "'")
            .replacingOccurrences(of: "Ccedil;", with: "Ç")
            .replacingOccurrences(of: "ouml;", with: "ő") ?? ""
          articles[$0.offset].link = items[$0.offset].link.text ?? ""
          articles[$0.offset].date = PublicationDate.short(from: items[$0.offset].pubDate.text ?? "")
          articles[$0.offset].image = $0.element.content.header.figure.img.attributes["src"] ?? ""
          articles[$0.offset].html = htmls[$0.offset]
        })
        self.articles = articles
        
      case .failure(let error):
        print(error)
      }
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

struct HTMLTags {
  static var margin: Int {
    return 5
  }
  static var fontSize: Int {
    let result = UIDevice.current.userInterfaceIdiom == .pad ? 30 : 44
    return result
  }
  static var suffix: String {"</body></html>"}
  static var prefix: String {
  """
  <html>
  <head>
  <style type=\"text/css\"> body {margin: \(margin)%;
    font-family: \"SFUIText-Regular\";
    font-size: \(fontSize);
    line-height:52px;}
    img { max-width: 100%; width: auto; height: auto; }
    iframe { max-width: atuo; width: auto; height: auto; }
    h1 {line-height: 75px; text-align:center;}
  </style>
  </head><body>
  """
  }

}
