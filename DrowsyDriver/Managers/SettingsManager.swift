//
//  SettingsManager.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import Foundation

fileprivate enum Settings {
    static let AlarmSound = "AlarmSound"
    static let QuickNavigate = "QuickNavigate"
}

class SettingsManager {
    
    enum AlarmSound: String, CaseIterable {
        case airhorn = "Airhorn"
        case alarm = "Alarm"
        case beep = "Beep"
    }
    
    private let defaultQuickNavigation = "Truck Stop"
    
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var alarmSound: AlarmSound {
        get { return AlarmSound(rawValue: defaults.string(forKey: Settings.AlarmSound)!)! }
        set { defaults.set(newValue.rawValue, forKey: Settings.AlarmSound) }
    }
    
    var quickNavigateQuery: String {
        get { return defaults.string(forKey: Settings.QuickNavigate)! }
        set { defaults.set(newValue.isEmpty ? quickNavigateQuery : newValue, forKey: Settings.QuickNavigate) }
    }
    
    func registerDefaults() {
        UserDefaults.standard.register(defaults: [Settings.AlarmSound: AlarmSound.beep.rawValue])
        UserDefaults.standard.register(defaults: [Settings.QuickNavigate: defaultQuickNavigation])
    }
}
