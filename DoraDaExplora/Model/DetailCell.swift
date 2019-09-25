//
//  detailCell.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/25/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

   var detailLabel = UILabel()
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      addSubview(detailLabel)
      setDetailLabelConstraints()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   
   func setDetailLabelConstraints() {
      detailLabel.translatesAutoresizingMaskIntoConstraints = false
      detailLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 100).isActive = true
      detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
      detailLabel.textAlignment = .right
      detailLabel.adjustsFontSizeToFitWidth = true
   }
}
