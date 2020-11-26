//
//  UserInformationViewController.swift
//  TemplateForWebViewBasedApps
//
//  Created by Maxim Gaysin on 30/09/2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

protocol UserInformationViewControllerDelegate {
  func closeUserInformationViewController()
}

class UserInformationViewController: UIViewController {
//MARK: Properties
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var surnameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var documentTextField: UITextField!
  
  @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
  
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var clearButton: UIButton!
  
  var delegate: UserInformationViewControllerDelegate?
  
  var preferredLanguage: String {
    get {return Languages.findLanguage()}
  }
  
  var name: String? {
    get {return Storage.userDefaults.string(forKey: "name")}
    set {Storage.userDefaults.set(newValue, forKey: "name")}
  }

  var surname: String? {
    get {return Storage.userDefaults.string(forKey: "surname")}
    set {Storage.userDefaults.set(newValue, forKey: "surname")}
  }
  
  var email: String? {
    get {return Storage.userDefaults.string(forKey: "email")}
    set {Storage.userDefaults.set(newValue, forKey: "email")}
  }
  
  var phoneNumber: String? {
    get {return Storage.userDefaults.string(forKey: "phoneNumber")}
    set {Storage.userDefaults.set(newValue, forKey: "phoneNumber")}
  }
  
  var document: String? {
    get {return Storage.userDefaults.string(forKey: "document")}
    set {Storage.userDefaults.set(newValue, forKey: "document")}
  }

  
  //MARK: Methods
  @IBAction func closeButtonTouch(_ sender: UIButton) {
    delegate?.closeUserInformationViewController()
  }
  @IBAction func clearButtonTouch(_ sender: UIButton) {
    let keys = ["name", "surname", "email", "phoneNumber", "gender", "document"]
    for key in keys {
      Storage.userDefaults.removeObject(forKey: key)
    }
    nameTextField.text = name
    surnameTextField.text = surname
    emailTextField.text = email
    phoneTextField.text = phoneNumber
    documentTextField.text = document
    genderSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    genderSegmentedControl.setNeedsLayout()
    }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupButtons()
    setupGenderSegmentedControl()
    nameTextField.text = name
    surnameTextField.text = surname
    emailTextField.text = email
    phoneTextField.text = phoneNumber
    documentTextField.text = document
     }
  
//MARK: - Buttons Setup
  func setupButtons() {
    continueButton.backgroundColor = ControlPanel.continueButtonBackgroundColor
    clearButton.backgroundColor = ControlPanel.clearButtonBackgroundColor
    continueButton.layer.cornerRadius = ControlPanel.userInformationViewButtonsCornerRadius
    clearButton.layer.cornerRadius = ControlPanel.userInformationViewButtonsCornerRadius
  }
//MARK: - GenderSegmentedControl stuff
  
  
  func setupGenderSegmentedControl() {
    
    switch preferredLanguage {
    case "ru", "es", "de", "pl", "nl":
      genderSegmentedControl.removeSegment(at: 3, animated: false)
      genderSegmentedControl.removeSegment(at: 2, animated: false)
    case "da", "fi", "fr", "it", "nb", "el":
      genderSegmentedControl.removeSegment(at: 3, animated: false)
    default: break
    }
    
    genderSegmentedControl.selectedSegmentIndex = Storage.userDefaults.integer(forKey: "gender")
    genderSegmentedControl.backgroundColor = ControlPanel.segmentedControlBackgroundColor
    genderSegmentedControl.addTarget(self, action: #selector(genderValueChanged(_:)), for: .valueChanged)
  }
  
  @objc func genderValueChanged(_ sender: UISegmentedControl) {
    Storage.userDefaults.set(genderSegmentedControl.selectedSegmentIndex, forKey: "gender")
  }
}
//MARK: - UITextFieldDelegate
extension UserInformationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField {
    case nameTextField:
      name = textField.text
    case surnameTextField:
      surname = textField.text
    case emailTextField:
      email = textField.text
    case phoneTextField:
      phoneNumber = textField.text
    case documentTextField:
      document = textField.text
    default:
      break
    }
  }
}

