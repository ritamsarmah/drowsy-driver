//
//  SettingsViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/17/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class SettingsViewController: GradientTableViewController {
    
    // MARK: - Properties
    private var doneButton: UIButton!
    private var alarmSwitch: UISwitch!
    
    // MARK: Cells
    @IBOutlet weak var alarmSoundCell: UITableViewCell!
    @IBOutlet weak var periodicRestCell: UITableViewCell!
    
    override var allCells: [UITableViewCell] {
        return [alarmSoundCell,
                periodicRestCell]
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarmSoundCell.detailTextLabel?.text = SettingsManager.shared.alarmSound.rawValue
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
