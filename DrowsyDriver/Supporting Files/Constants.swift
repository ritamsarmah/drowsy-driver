//
//  Constants.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

enum EyeAspectRatio {
    static let Threshold: Float = 0.2               // If EAR falls below threshold, eyes are closed
    static let TimeInterval: TimeInterval = 2.0     // If seconds of closed eyes exceeds threshold, turn on alarm
}

enum Colors {
    enum Background {
        static let Main = [
            UIColor(red: 0.318, green: 0.827, blue: 0.961, alpha: 1.0), // #51D3F5
            UIColor(red: 0.145, green: 0.69, blue: 0.592, alpha: 1.0) // #25B097
        ]
        static let Warning = [
            UIColor(red: 0.961, green: 0.318, blue: 0.318, alpha: 1.0), // #F55151
            UIColor(red: 0.827, green: 0.588, blue: 0.098, alpha: 1.0) // #D39619
        ]
        static let Dark = UIColor.black
    }
    
    static let DarkText = UIColor.black
    static let DisplayText = UIColor.white
    static let Translucent = UIColor(white: 1.0, alpha: 0.65)
    static let TableViewCellNormal = UIColor(white: 1.0, alpha: 0.25)
    static let TableViewCellSelected = UIColor(white: 1.0, alpha: 0.50)
    static let Button = Colors.Translucent
}

enum Fonts {
    private static let fontName = "Avenir"
    static let DisplayNormal = UIFont(name: "\(fontName)-Book", size: 30)!
    static let DisplayBold = UIFont(name: "\(fontName)-Heavy", size: 30)!
    
    static let ButtonText = UIFont(name: "\(fontName)-Heavy", size: 18)!
    static let ButtonTextLight = UIFont(name: "\(fontName)-Book", size: 18)!
    
    static let NavigationTitle = UIFont(name: "\(fontName)-Medium", size: 20)!
    static let NavigationButton = UIFont(name: "\(fontName)-Roman", size: 18)!
    static let TableViewCell = UIFont(name: "\(fontName)-Roman", size: 16)!
    static let TableViewAccessory = UIFont(name: "\(fontName)-Book", size: 24)!
}
