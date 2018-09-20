//
//  Alert.swift
//  VideoStreamer
//
//  Created by Ritam Sarmah on 8/9/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

struct Alert {
    
    private init() {}
    
    private static let okAction = UIAlertAction(title: "OK", style: .default)
    private static let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    static func presentAlert(on viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction] = [okAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        viewController.present(alert, animated: true)
    }
    
    static func presentActionSheet(on viewController: UIViewController, title: String?, message: String?, actions: [UIAlertAction] = [cancelAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        viewController.present(alert, animated: true)
    }
    
    // MARK: Helper Methods for Error Presentation
    
    static func presentError(on viewController: UIViewController, _ error: NSError) {
        Alert.presentAlert(on: viewController, title: "Failed with error \(error.code)", message: error.localizedDescription)
    }
    
    static func presentDefaultError(on viewController: UIViewController) {
        Alert.presentAlert(on: viewController, title: "An unexpected failure occurred", message: nil)
    }
    
    // MARK: Authorization Alerts
    
    static func presentCameraAccessNeeded(on viewController: UIViewController) {
        presentAlert(on: viewController, title: "Camera Access Needed", message: "DrowsyDriver needs access to your camera to detect your face. Please enable it in your settings.")
    }
    
    
    // MARK: Help and Warnings
    static func presentFaceDetectionHelp(on viewController: UIViewController) {
        presentAlert(on: viewController, title: "", message: "Place your phone in a stable position directly in front of you or angled toward your face. Both eyes should be visible with yellow outlines. If the alignment is inaccurate, cover and uncover the front-facing camera to reset the tracking.")
    }

}
