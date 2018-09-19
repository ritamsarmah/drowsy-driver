//
//  TimeInterval+String.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/18/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import Foundation

extension TimeInterval {
    func hoursMinutesDescription() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}
