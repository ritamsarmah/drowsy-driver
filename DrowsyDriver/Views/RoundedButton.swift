//
//  RoundedButton.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateUI()
    }
    
    func updateUI() {
        self.titleLabel?.font = Fonts.ButtonText
        self.setTitleColor(.black, for: .normal)
        self.backgroundColor = Colors.Button
        self.setBackgroundColor(color: UIColor(white: 1.0, alpha: 0.7), forState: .highlighted)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
    }
    
}
