//
//  UIImageView + cache.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 03.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
  
  func loadFromURL(string: String) {
    guard let url = URL(string: string) else { return }
    DispatchQueue.main.async {
      self.image = nil
    }
    
    if let cachedImage = imageCache.object(forKey: string as NSString) {
      DispatchQueue.main.async {
        self.image = cachedImage
      }
      return
    }
    
    Networking.downloadImage(url: url) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let data):
        guard  let image = UIImage(data: data) else { return }
        imageCache.setObject(image, forKey: url.absoluteString as NSString)
          self.image = image
      case .failure(let error):
        print(error)
          self.image = nil
      }
    }
  }
}
