//
//  Article.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 02.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit
import SwiftyXMLParser

struct Article {
  var title: String
  var date: String
  var image: String
  var html: HTML
  
  static let empty = Article(title: "", date: "", image: "", html: HTML(""))
}

extension Article {
  
  init(_ item: XML.Accessor) {
    var textInContentTag = ("<content>" + (item["turbo:content"].text ?? "") + "</content>")
    textInContentTag.removeHTMLEscape()
    let xmlInContentTag = try? XML.parse(textInContentTag)
    self.title = xmlInContentTag?.content.header.h1.text ?? ""
    self.date = PublicationDate.short(from: item.pubDate.text ?? "")
    self.image = textInContentTag.slice(from: "src=\"", to: "\"") ?? ""
    self.html = HTML((item["turbo:content"].text ?? ""))
  }
}

typealias Articles = [Article]

extension Articles {
  init?(_ data: Data, channel: Channels) {
    var items: [XML.Accessor] = []
    var articles: Articles = []
    for item in XML.parse(data).rss.channel.item {
      items.append(item)
      articles.append(Article(item))
    }
    items.removeFirst(channel.fakeItemsNumber)
    articles.removeFirst(channel.fakeItemsNumber)
    print("Всего статей - \(articles.count)")
    self = articles
  }
}

struct HTML {
  //
  static var prefix: String {
    """
  <html>
  <head>
  <style type=\"text/css\">
    body {margin: \(margin)%;
    font-family: \"SFUIText-Regular\";
    font-size: \(fontSize);
    line-height:52px;}
    img { max-width: 100%; width: auto; height: auto; }
    iframe { max-width: atuo; width: auto; height: auto; }
    h1 {line-height: 75px; text-align:center;}
    p {text-align: justify}
  </style>
  </head><body>
  """
  }
  static var suffix: String {"</body></html>"}
  static var margin: Int {
    return 5
  }
  static var fontSize: Int {
    let result = UIDevice.current.userInterfaceIdiom == .pad ? 30 : 44
    return result
  }
  
  
  
  private (set) var content: HTMLFileContent
  
  public init(_ string: String) {
    guard !string.isEmpty else {self.content = string; return }
    var cnt = string
    self.content = cnt.prepareForWebView()
  }
}

typealias HTMLFileContent = String
extension HTMLFileContent {
  var validString: String {
    var result = self
    result.removeHTMLEscape()
    return result
  }
  private var hasDoubleHeader: Bool {
    if let xml = try? XML.parse(validString) {
      if (xml.html.body.header.h1.text == xml.html.body.h1.text) && (xml.html.body.header.h1.text != nil) {
        return true
      }
    }
    return false
  }
  
  public mutating func removeHTMLEscape() {
    self = self.replacingOccurrences(of: "&quot;", with: "\'")
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&laquo;", with: "\"")
      .replacingOccurrences(of: "&raquo;", with: "\"")
      .replacingOccurrences(of: "&nbsp;", with: " ")
      .replacingOccurrences(of: "&ndash;", with: " - ")
      .replacingOccurrences(of: "&#039;", with: "'")
      .replacingOccurrences(of: "&Ccedil;", with: "Ç")
      .replacingOccurrences(of: "&ouml;", with: "ő")
      .replacingOccurrences(of: "&", with: "")
  }
  
  public mutating func prepareForWebView() -> Self {
    addTags()
    
    if hasDoubleHeader {removeRedundantHeader()}  
    removeTag("menu")
    removeTag("figure")
    return self
  }
  
  private mutating func removeTag(_ tag: String) {
    self = removeBetween("<\(tag)>", "</\(tag)>") ?? self
  }
  
  private mutating func addTags() {
    self = HTML.prefix + self + HTML.suffix
  }
  
  
  private mutating func removeRedundantHeader() {
    removeTag("header")
  }
}
