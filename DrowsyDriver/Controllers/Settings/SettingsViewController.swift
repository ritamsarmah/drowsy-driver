//
//  SettingsViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/17/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class SettingsViewController: GradientTableViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var quickNavTextLabel: UILabel!
    @IBOutlet weak var quickNavTextField: UITextField!
    
    // MARK: Cells
    @IBOutlet weak var alarmSoundCell: UITableViewCell!
    @IBOutlet weak var periodicRestCell: UITableViewCell!
    @IBOutlet weak var quickNavCell: UITableViewCell!
    
    override var allCells: [UITableViewCell] {
        return [alarmSoundCell,
                periodicRestCell,
                quickNavCell]
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
        quickNavTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarmSoundCell.detailTextLabel?.text = SettingsManager.shared.alarmSound.rawValue
        quickNavTextField.text = SettingsManager.shared.quickNavigateQuery
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func updateUI() {
        super.updateUI()
        
        // Quick Nav
        quickNavCell.selectionStyle = .none
        updateCellAppearance(for: quickNavCell)
        updateLabelAppearance(for: quickNavTextLabel)
        updateTextFieldAppearance(for: quickNavTextField)
    }
    
    // MARK: - Text Field Functions
    @objc func dismissKeyboard() {
        view.endEditing(true)
        updateQuickNav()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == quickNavTextField {
            updateQuickNav()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if textField == quickNavTextField {
            updateQuickNav()
        }
    }
    
    func updateQuickNav() {
        if let text = quickNavTextField.text {
            SettingsManager.shared.quickNavigateQuery = text
        }
        quickNavTextField.text = SettingsManager.shared.quickNavigateQuery
    }
    
}
