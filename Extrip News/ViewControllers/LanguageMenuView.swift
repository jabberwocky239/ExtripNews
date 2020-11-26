//
//  LanguageMenuView.swift
//  Aeroexpress
//
//  Created by Maxim Gaysin on 06.11.2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

protocol LanguageMenuViewDelegate {
  func buttonPressed(with title: String )
}

class LanguageMenuView: UIView {
  ///title font size
  private let font = UIFont.boldSystemFont(ofSize: 40)
  
  private  let titles = ["🇷🇺", "🇬🇧", "🇩🇪", "🇨🇳"]
  
  lazy var buttons: [UIButton] = {
    var bttns = [UIButton]()
    for title in titles {
      let frame = CGRect(origin: CGPoint(x: 0, y: 0),
                         size: CGSize(width: self.bounds.width, height: self.bounds.height/4))
      let button = UIButton(frame: frame)
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = font
      button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
      bttns.append(button)
    }
    return bttns
  }()
  
  var delegate: LanguageMenuViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  convenience init (origin: CGPoint) {
    let frame = CGRect(x: origin.x,
                       y: origin.y,
                       width: 60,
                       height: 180)
    self.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    layer.borderColor = UIColor.darkGray.cgColor
    layer.borderWidth = 0
    backgroundColor = .white
    arrangeButtons()
  }
  
  private func arrangeButtons() {
    var y: CGFloat = 0
    for button in buttons {
      button.frame.origin.y = y
      y += self.bounds.height/CGFloat(buttons.count)
     addSubview(button)
    }
  }
  
  @objc func buttonTapped(sender: UIButton) {
    delegate?.buttonPressed(with: sender.titleLabel!.text!)
  }
}
