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
    

}