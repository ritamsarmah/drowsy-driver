//
//  TimeTracker.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import Foundation

class TimeTracker {
    
    private(set) var name: String
    
    private var timer: RepeatingTimer
    
    var isTracking: Bool = false
    
    var elapsedSeconds = 0.0
    
    var elapsedTime: String {
        let hours = Int(elapsedSeconds) / 3600
        let minutes = Int(elapsedSeconds) / 60 % 60
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
    
    var precision = 1.0 {
        didSet {
            timer = RepeatingTimer(timeInterval: precision)
            timer.eventHandler = update
        }
    }
    
    var notification: Notification {
        return Notification(name: Notification.Name(name))
    }
    
    init(name: String) {
        self.name = name
        timer = RepeatingTimer(timeInterval: precision)
        timer.eventHandler = update
    }
    
    func start() {
        elapsedSeconds = 0
        resume()
    }
    
    func stop() {
        elapsedSeconds = 0
        pause()
    }
    
    func resume() {
        timer.resume()
        isTracking = true
    }
    
    func pause() {
        timer.suspend()
        isTracking = false
    }
    
    private func update() {
        elapsedSeconds += precision
        NotificationCenter.default.post(notification)
    }
}
