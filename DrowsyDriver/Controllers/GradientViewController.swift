//
//  GradientViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/18/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class GradientViewController: UIViewController {

    private var backgroundView = UIView()
    
    // Child of backgroundView
    private var backgroundGradientView = UIView() {
        didSet {
            backgroundView.addSubview(backgroundGradientView)
        }
    }
    
    private var backgroundGradientLayer: CAGradientLayer! {
        didSet {
            let newBackgroundGradientView = UIView(frame: self.backgroundView.bounds)
            newBackgroundGradientView.layer.insertSublayer(backgroundGradientLayer, at: 0)
            backgroundGradientView = newBackgroundGradientView
        }
    }
    
    var backgroundGradient = Colors.Background.Main {
        didSet {
            setBackgroundGradient(to: backgroundGradient)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.clipsToBounds = true
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundGradient(to: backgroundGradient)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setBackgroundGradient(to: backgroundGradient, frame: CGRect(origin: view.frame.origin, size: size))
    }
    
    private func setBackgroundGradient(to colors: [UIColor], frame: CGRect? = nil) {
        let newLayer = CAGradientLayer()
        newLayer.colors = colors.map { $0.cgColor }
        newLayer.locations = [0.0, 1.0]
        newLayer.frame = frame ?? view.frame
        newLayer.frame = newLayer.frame.applying(CGAffineTransform(scaleX: 2, y: 2))
        backgroundGradientLayer = newLayer
    }

}
