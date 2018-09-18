//
//  GradientViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/18/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class GradientViewController: UIViewController {

    private var backgroundGradientLayer: CAGradientLayer! {
        didSet {
            if oldValue != nil {
                view.layer.replaceSublayer(oldValue, with: backgroundGradientLayer)
            } else {
                view.layer.insertSublayer(backgroundGradientLayer, at: 0)
            }
        }
    }
    
    var backgroundGradient = Colors.Background.Main {
        didSet {
            backgroundGradientLayer = createGradient(for: backgroundGradient)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        backgroundGradientLayer = createGradient(for: backgroundGradient, frame: CGRect(origin: .zero, size: size))
    }
    
    private func createGradient(for colors: [UIColor], frame: CGRect? = nil) -> CAGradientLayer {
        let newLayer = CAGradientLayer()
        newLayer.frame = frame ?? view.frame
        newLayer.colors = colors.map { $0.cgColor }
        newLayer.locations = [0.0, 1.0]
        return newLayer
    }

}
