//
//  CopyBoardView.swift
//  Aeroexpress
//
//  Created by Maxim Gaysin on 10.11.2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

protocol CopyBoardViewDelegate {
  func closeButtonTouch()
}

class CopyBoardView: UIView {
  
  var delegate: CopyBoardViewDelegate?
  var swipeToTheBottom: UISwipeGestureRecognizer!
  
  private let padding: CGFloat = 4
  
  private let titles:[String] = [NSLocalizedString("Name", comment: ""),
                        NSLocalizedString("Surname", comment: ""),
                        NSLocalizedString("Email", comment: ""),
                        NSLocalizedString("Document", comment: "")]
  
  lazy var buttons: [UIButton] = {
    var bttns = [UIButton]()
    for title in titles {
      let frame = CGRect(origin: CGPoint(x: 0, y: 0),
                         size: CGSize(width: self.bounds.width, height: self.bounds.height/4))
      let button = UIButton(frame: frame)
      button.setTitle("☑️" + title, for: .normal)
      button.setTitleColor(.darkGray, for: .normal)
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
      button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
      bttns.append(button)
    }
    return bttns
  }()
  
  
  lazy var closeButton: UIButton = {
    let button = UIButton(frame: CGRect(x: self.bounds.width - self.bounds.height/5,
                                        y: 0,
                                        width: self.bounds.height/5,
                                        height: self.bounds.height/5))
    button.setTitle("✖️", for: .normal)
    button.backgroundColor = ControlPanel.clearButtonBackgroundColor
    button.addTarget(self, action: #selector(closeButtonTouch), for: .touchUpInside)
    return button
  }()
  
  lazy var label: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("Copy to the clipboard", comment: "")
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.sizeToFit()
    return label
  }()
  
  lazy var mainStackView: UIStackView = {
    let sv = UIStackView(frame: CGRect(x: padding,
                                       y: padding,
                                       width: UIScreen.main.bounds.width,
                                       height: self.bounds.height))
    sv.axis = .vertical
    sv.alignment = .center
    sv.distribution = .fillProportionally
    sv.spacing = padding
    return sv
  }()
  
  lazy var horizontalStacks: [UIStackView] = {
    var svArr = [UIStackView]()
    for index in buttons.indices {
      let sv = UIStackView(frame: CGRect(x: padding,
                                         y: padding,
                                         width: UIScreen.main.bounds.width,
                                         height: self.bounds.height/4))
      sv.axis = .horizontal
      sv.alignment = .center
      sv.distribution = .equalCentering
      sv.spacing = padding
      svArr.append(sv)
    }
    return svArr
  }()
  
  override init(frame: CGRect) {
      super.init(frame: frame)
    }
    
    convenience init (origin: CGPoint) {
      let frame = CGRect(x: origin.x,
                         y: origin.y,
                         width: UIScreen.main.bounds.width,
                         height: UIScreen.main.bounds.height/4)
      self.init(frame: frame)
      setupView()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  
    private func setupView() {
      backgroundColor = .lightGray
      addSubview(closeButton)
      addSubview(mainStackView)
      addStacks()
      horizontalStacks[0].addArrangedSubview(label)
      addButtons()
      bringSubviewToFront(closeButton)
      setupGestureRecognizer()
  }
  
  func addButtons() {
    for (index, button) in buttons.enumerated() {
      switch index {
      case 0, 1:
        horizontalStacks[1].addArrangedSubview(button)
      case 2, 3:
        horizontalStacks[2].addArrangedSubview(button)
      default:
        break
      }
    }
  }
  
  func addStacks() {
    for stack in horizontalStacks {
      stack.frame.size = CGSize(width: UIScreen.main.bounds.width, height: self.bounds.height/4)
      mainStackView.addArrangedSubview(stack)
    }
  }
  
  @objc func buttonTapped(sender: UIButton) {
    var newLabel = ""
    if let oldText = sender.titleLabel?.text {
      newLabel = oldText
      newLabel.remove(at: newLabel.startIndex)
    }
    print(newLabel)
    
      switch sender {
      case let button where button == buttons[0]:
        if let name = Storage.userDefaults.string(forKey: "name") {
          UIPasteboard.general.string = name
          self.buttons[0].setTitle("✅" + newLabel, for: .normal)
          self.setNeedsDisplay()
        }
      case let button where button == buttons[1]:
        if let surname = Storage.userDefaults.string(forKey: "surname") {
          UIPasteboard.general.string = surname
          self.buttons[1].setTitle("✅" + newLabel, for: .normal)
        }
      case let button where button == buttons[2]:
        if let email = Storage.userDefaults.string(forKey: "email") {
          UIPasteboard.general.string = email
          self.buttons[2].setTitle("✅" + newLabel, for: .normal)

        }
      case let button where button == buttons[3]:
        if let document = Storage.userDefaults.string(forKey: "document") {
          UIPasteboard.general.string = document
          self.buttons[3].setTitle("✅" + newLabel, for: .normal)
        }
      default:
        break
      }
  }
 
  @objc func closeButtonTouch(sender: UIButton) {
    delegate?.closeButtonTouch()
  }
  
  func setupGestureRecognizer() {
    swipeToTheBottom = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
    swipeToTheBottom.direction = .down
    self.addGestureRecognizer(swipeToTheBottom)
    
  }
  
  @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
    delegate?.closeButtonTouch()
  }
}
