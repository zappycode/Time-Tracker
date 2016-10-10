//
//  TimeTableInterfaceController.swift
//  Time Tracker
//
//  Created by Nick Walter on 9/27/16.
//  Copyright © 2016 Zappy Code. All rights reserved.
//

import WatchKit
import Foundation


class TimeTableInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var clockIns : [Date] = []
    var clockOuts : [Date] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        if let clockIns = UserDefaults.standard.array(forKey: "clockIns") as? [Date] {
            self.clockIns = clockIns
        }
        if let clockOuts = UserDefaults.standard.array(forKey: "clockOuts") as? [Date] {
            self.clockOuts = clockOuts
        }
        
        
        table.setNumberOfRows(clockIns.count, withRowType: "clockInOutRow")
        
        for index in 0..<clockIns.count {
            if let rowController = table.rowController(at: index) as? ClockInOutRowController {
                
                let currentSeconds = Int(clockOuts[index].timeIntervalSince(clockIns[index]))
                
                let hours = currentSeconds / 3600
                let minutes = (currentSeconds % 3600) / 60
                let seconds = currentSeconds % 60
                
                var timeWorkedString = ""
                
                if hours != 0 {
                    timeWorkedString += "\(hours)h "
                }
                if minutes != 0 || hours != 0 {
                    timeWorkedString += "\(minutes)m "
                }
                
                timeWorkedString += "\(seconds)s"
                
                rowController.label.setText(timeWorkedString)
            }
        }
        
    }

    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "TimeDetail", context: [clockIns[rowIndex],clockOuts[rowIndex]])
    }

}
