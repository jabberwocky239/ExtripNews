//
//  URLSession + REsult.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 02.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//

import Foundation

enum NetworkRequestError: Error {
    case unknown(Data?, URLResponse?)
}
extension URLSession {

  static func request(url: URL, parameters: [String: String], completion: @escaping (Result<Data, Error>) -> ()) {
      let request = URLRequest(url: url)
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let responseData = data, error == nil else {
              completion(.failure(error ?? NetworkRequestError.unknown(data, response)))
              return
          }

          completion(.success(responseData))
      }
      task.resume()
  }
}
