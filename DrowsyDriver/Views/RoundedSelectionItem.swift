//
//  RoundedSelectionItem.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/18/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class RoundedSelectionItem: RoundedButton {
    
    var textLabel: UILabel!
    var detailLabel: UILabel!
    var icon: UIImageView!
    var accessoryView: UILabel!

    var textStackView: UIStackView!
    var stackView: UIStackView!
    
    var padding: CGFloat = 16
    
    override func updateUI() {
        super.updateUI()
        textLabel = UILabel()
        textLabel.font = Fonts.ButtonText
        textLabel.textColor = Colors.DarkText
        textLabel.baselineAdjustment = .alignCenters
        
        detailLabel = UILabel()
        detailLabel.font = Fonts.ButtonTextLight
        detailLabel.textColor = Colors.DarkText
        detailLabel.baselineAdjustment = .alignCenters
        
        textStackView = UIStackView(arrangedSubviews: [textLabel, detailLabel])
        textStackView.axis = .vertical
        textStackView.backgroundColor = .green
        textStackView.distribution = .fillEqually
        
        icon = UIImageView(image: UIImage(named: "geo_fence"))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        accessoryView = UILabel()
        accessoryView.font = Fonts.DisplayNormal
        accessoryView.textColor = Colors.DarkText
        accessoryView.text = "›"
        accessoryView.baselineAdjustment = .alignCenters
        accessoryView.sizeToFit()
        
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        stackView = UIStackView(arrangedSubviews: [icon, textStackView, accessoryView])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding).isActive = true
        stackView.isUserInteractionEnabled = false
        
    }

}
