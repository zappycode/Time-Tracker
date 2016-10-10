//
//  InterfaceController.swift
//  Time Tracker WatchKit Extension
//
//  Created by Nick Walter on 9/15/16.
//  Copyright © 2016 Zappy Code. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var topLabel: WKInterfaceLabel!
    @IBOutlet var middleLabel: WKInterfaceLabel!
    @IBOutlet var button: WKInterfaceButton!
    
    var clockedIn = false
    
    var timer : Timer? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
    }
    
    override func willActivate() {
        if UserDefaults.standard.value(forKey: "clockedIn") != nil {
            
            if timer == nil {
                startUpTimer()
            }
            
            clockedIn = true
            
            updateUI(clockedIn: true)
        } else {
            clockedIn = false
            updateUI(clockedIn: false)
        }
    }
    
    func updateUI(clockedIn:Bool) {
        if clockedIn {
            // THE UI FOR WHEN SOMEONE IS CLOCKED IN
            
            topLabel.setHidden(false)
            self.topLabel.setText("Today: \(totalTimeWorkedAsString())")
            middleLabel.setText("0s")
            button.setTitle("Clock-Out")
            button.setBackgroundColor(UIColor.red)
        } else {
            // THE UI FOR WHEN SOMEONE IS CLOCKED OUT
            
            topLabel.setHidden(true)
            button.setTitle("Clock-In")
            button.setBackgroundColor(UIColor.green)
            
            middleLabel.setText("Today\n\(totalTimeWorkedAsString())")
        }
    }
    
    @IBAction func clockInOutTapped() {
        if clockedIn {
            clockOut()
        } else {
            clockIn()
        }
        updateUI(clockedIn: clockedIn)
    }
    
    func startUpTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
                let timeInterval = Int(Date().timeIntervalSince(clockedInDate))
                
                let hours = timeInterval / 3600
                let minutes = (timeInterval % 3600) / 60
                let seconds = timeInterval % 60
                
                var currentClockedInString = ""
                
                if hours != 0 {
                    currentClockedInString += "\(hours)h "
                }
                if minutes != 0 || hours != 0 {
                    currentClockedInString += "\(minutes)m "
                }
                
                currentClockedInString += "\(seconds)s"
                
                
                self.middleLabel.setText(currentClockedInString)
                
                self.topLabel.setText("Today: \(self.totalTimeWorkedAsString())")
            }
        }
    }
    
    func clockIn() {
        clockedIn = true
        
        UserDefaults.standard.set(Date(), forKey: "clockedIn")
        UserDefaults.standard.synchronize()
        
        startUpTimer()
    }
    
    func clockOut() {
        clockedIn = false
        
        timer?.invalidate()
        timer = nil
        
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
            // Adding the clockin time to the clockins array
            if var clockIns = UserDefaults.standard.array(forKey: "clockIns") as? [Date] {
                clockIns.insert(clockedInDate, at: 0)
                UserDefaults.standard.set(clockIns, forKey: "clockIns")
                print(clockIns)
            } else {
                UserDefaults.standard.set([clockedInDate], forKey: "clockIns")
            }
            
            // Adding the clockout time to the clockouts array
            if var clockOuts = UserDefaults.standard.array(forKey: "clockOuts") as? [Date] {
                clockOuts.insert(Date(), at: 0)
                UserDefaults.standard.set(clockOuts, forKey: "clockOuts")
                print(clockOuts)
            } else {
                UserDefaults.standard.set([Date()], forKey: "clockOuts")
            }
            
            UserDefaults.standard.set(nil, forKey: "clockedIn")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func totalClockedTime() -> Int {
        if var clockIns = UserDefaults.standard.array(forKey: "clockIns") as? [Date] {
            if var clockOuts = UserDefaults.standard.array(forKey: "clockOuts") as? [Date] {
                
                var seconds = 0
                for index in 0..<clockIns.count {
                    
                    // Find the seconds between clockin and out
                    let currentSeconds = Int(clockOuts[index].timeIntervalSince(clockIns[index]))
                    
                    
                    
                    // Add time to seconds
                    
                    seconds += currentSeconds
                }
                
                return seconds
            }
        }
        
        return 0
    }
    
    func totalTimeWorkedAsString() -> String {
        
        var currentClockedInSeconds = 0
        
        if let clockedInDate = UserDefaults.standard.value(forKey: "clockedIn") as? Date {
            currentClockedInSeconds = Int(Date().timeIntervalSince(clockedInDate))
        }
        
        let totalTimeInterval = currentClockedInSeconds + self.totalClockedTime()
        let totalHours = totalTimeInterval / 3600
        let totalMinutes = (totalTimeInterval % 3600) / 60
        
        return "\(totalHours)h \(totalMinutes)m"
        
    }
    @IBAction func resetAllTapped() {
        UserDefaults.standard.set(nil, forKey: "clockedIn")
        UserDefaults.standard.set(nil, forKey: "clockIns")
        UserDefaults.standard.set(nil, forKey: "clockOuts")
        
        UserDefaults.standard.synchronize()
        
        updateUI(clockedIn: false)
    }
    
    
    @IBAction func historyTapped() {
        pushController(withName: "TimeTableController", context: nil)
    }
}
