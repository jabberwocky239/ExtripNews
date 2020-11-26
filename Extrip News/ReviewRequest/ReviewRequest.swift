//
//  ReviewRequest.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 07/10/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import Foundation

import StoreKit

struct Storage {
  static var userDefaults = UserDefaults.standard
}

struct UserDefaultsKeys {
  static let processCompletedCountKey: String = "processCompletedCount"
  
  
  static let lastVersionPromptedForReviewKey: String = "lastVersionPromptedForReview"
  
}

struct ReviewRequest {
  static var shared = ReviewRequest()
  
  // If the count has not yet been stored, this will return 0
  var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.processCompletedCountKey)
  public mutating func promptReview() {
    count += 1
    UserDefaults.standard.set(count, forKey: UserDefaultsKeys.processCompletedCountKey)
    print("Process completed \(count) time(s)")
    
    // Get the current bundle version for the app
    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
      else { fatalError("Expected to find a bundle version in the info dictionary") }
    
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
    
    // Has the process been completed several times and the user has not already been prompted for this version?
    if count >= 10 && currentVersion != lastVersionPromptedForReview {
      let twoSecondsFromNow = DispatchTime.now() + 2.0
      DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
        SKStoreReviewController.requestReview()
        UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
      }
    }
  }
}

