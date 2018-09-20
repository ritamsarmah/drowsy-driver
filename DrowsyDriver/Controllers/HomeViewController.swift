//
//  HomeViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit
import AVKit

class HomeViewController: GradientViewController {

    // MARK: - Properties
    private var startButton: RoundedButton!
    private var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            requestCameraAccess()
        }
    }
    
    @objc func startTrip() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            let vc = TripViewController()
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else {
            requestCameraAccess()
        }
    }
    
    func updateUI() {
        view.backgroundColor = .clear
        backgroundGradient = Colors.Background.Main
        
        // Start Button
        startButton = RoundedButton()
        startButton.setTitle("Start Driving", for: .normal)
        
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.widthAnchor.constraint(equalToConstant: Constraints.StartButton.width).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: Constraints.StartButton.height).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        startButton.addTarget(self, action: #selector(startTrip), for: .touchUpInside)
        
        // Settings Button
        settingsButton = UIButton(type: .system)
        let image = UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(image, for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constraints.SettingsButton.topConstant).isActive = true
        settingsButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.SettingsButton.rightConstant).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: Constraints.SettingsButton.width).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: Constraints.SettingsButton.height).isActive = true
    }
    
    @objc func openSettings() {
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigation") as! UINavigationController
        present(vc, animated: true, completion: nil)
    }
    
    @objc func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                Alert.presentCameraAccessNeeded(on: self)
            }
        }
    }
    
    private enum Constraints {
        enum SettingsButton {
            static let width: CGFloat = 44
            static let height: CGFloat = 44
            static let topConstant: CGFloat = 8
            static let rightConstant: CGFloat = -16
        }
        
        enum StartButton {
            static let height: CGFloat = 50
            static let width: CGFloat = 160
        }
    }
    
}
