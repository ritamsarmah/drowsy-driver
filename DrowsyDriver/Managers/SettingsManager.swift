//
//  SettingsManager.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import Foundation

fileprivate enum Settings {
    static let DarkMode = "DarkMode"
    static let AlarmSound = "AlarmSound"
}

class SettingsManager {
    
    enum AlarmSound: String, CaseIterable {
        case airhorn = "Airhorn"
        case alarm = "Alarm"
        case beep = "Beep"
    }
    
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var isDarkModeEnabled: Bool {
        get { return defaults.bool(forKey: Settings.DarkMode) }
        set { defaults.set(newValue, forKey: Settings.DarkMode) }
    }
    
    var alarmSound: AlarmSound {
        get { return AlarmSound(rawValue: defaults.string(forKey: Settings.AlarmSound)!)! }
        set { defaults.set(newValue.rawValue, forKey: Settings.AlarmSound) }
    }
    
    func registerDefaults() {
        UserDefaults.standard.register(defaults: [Settings.DarkMode: false])
        UserDefaults.standard.register(defaults: [Settings.AlarmSound: AlarmSound.beep.rawValue])
    }
}
