//
//  AlarmSoundViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/18/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit
import AVKit

class AlarmSoundViewController: GradientTableViewController {

    let cellIdentifier = "AlarmSoundCell"
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let index = SettingsManager.AlarmSound.allCases.firstIndex(of: SettingsManager.shared.alarmSound)!
        let row = SettingsManager.AlarmSound.allCases.distance(from: 0, to: index)
        tableView.cellForRow(at: IndexPath(row: row, section: 0))!.accessoryType = .checkmark
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        player = nil
    }
    
    func resetChecks() {
        for row in 0..<SettingsManager.AlarmSound.allCases.count {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                cell.accessoryType = .none
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsManager.AlarmSound.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = String(SettingsManager.AlarmSound.allCases[indexPath.row].rawValue)
        updateCellAppearance(for: cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resetChecks()
        
        let newSound = SettingsManager.AlarmSound.allCases[indexPath.row]
        if SettingsManager.shared.alarmSound != newSound {
            player?.pause()
            player = nil
        }
        
        SettingsManager.shared.alarmSound = newSound
        tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0))!.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Play sound
        if let player = player, player.isPlaying {
            player.pause()
        } else {
            let audioData = NSDataAsset(name: SettingsManager.shared.alarmSound.rawValue)!.data
            player = try! AVAudioPlayer(data: audioData)
            player?.play()
        }
    }
}
