//
//  MenuCellTableViewCell.swift
//  Aeroexpress
//
//  Created by Maxim Gaysin on 05.11.2019.
//  Copyright © 2019 Ekstrip, OOO. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

  var label: UILabel? = {
    let label = UILabel()
    label.textAlignment = .left
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 14)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    if let label = self.label {
      addSubview(label)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
