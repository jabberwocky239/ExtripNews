//
//  Networking.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 03.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//
import Foundation

final class Networking: NSObject {
  
  private static func getData(url: URL,
                              completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
  }
  
  public static func downloadImage(url: URL,
                                   completion: @escaping (Result<Data, Error>) -> Void) {
    Networking.getData(url: url) { data, response, error in
      
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data, error == nil else {
        return
      }
      
      DispatchQueue.main.async() {
        completion(.success(data))
      }
    }
  }
}
