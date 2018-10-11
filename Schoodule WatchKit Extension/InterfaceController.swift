//
//  InterfaceController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/4/18.
//  Copyright © 2018 Schoodule. All rights reserved.
//

import WatchKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var infoLabel: WKInterfaceLabel!
    @IBOutlet var scheduleTable: WKInterfaceTable!
    
    var storage: Storage {
        return ExtensionDelegate.storage
    }
    
    var todayEvents: [Event] {
        return ExtensionDelegate.getTodayEvents()
    }
    
    override func willActivate() {
        infoLabel.setHidden(false)

        createTable()
        
        ExtensionDelegate.connectivityController.sendRefresh {
            self.createTable()
            
            if self.todayEvents.isEmpty {
                self.infoLabel.setText("No classes today.")
                self.infoLabel.setHidden(false)
            } else {
                self.infoLabel.setHidden(true)
            }
        }
    }
    
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return todayEvents[rowIndex]
    }
    
    func createTable() {
        ExtensionDelegate.reloadTodayEvents()
        
        scheduleTable.setNumberOfRows(todayEvents.count, withRowType: "classRow")
        
        for (index, event) in todayEvents.enumerated() {
            loadRow(index: index, event: event)
        }
        
        reloadCurrent()
        showInfo()
    }
    
    func reloadCurrent() {
        let currentClass = storage.schedule.eventFrom(date: Date())
        let nextClass = storage.schedule.nextEventFrom(date: Date())

        for (index, period) in todayEvents.enumerated() {
            let row = scheduleTable.rowController(at: index) as! ClassRow
            if period == currentClass || (period == nextClass && currentClass == nil) {
                row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.14))
            } else {
                row.group.setBackgroundColor(UIColor.clear)
            }
        }
    }
    
    func loadRow(index: Int, event: Event) {
        let row = scheduleTable.rowController(at: index) as! ClassRow
        
        row.durationLabel?.setText("\(event.startDate.timeString)")
        row.indexLabel?.setText("\(index + 1)")
        row.nameLabel?.setText("\(event.name)")
        
        let color = UIColor(color: event.color)
        row.seperator?.setColor(color)
        row.indexLabel?.setTextColor(color)
        row.nameLabel?.setTextColor(color)
        row.durationLabel.setTextColor(UIColor.white)
        
        if event.location == "" {
            row.locationLabel.setHidden(true)
        } else {
            row.locationLabel.setText(event.location)
            row.locationLabel.setHidden(false)
        }
        
        let now = Date()
        if now > event.startDate && now < event.endDate {
            row.group.setBackgroundColor(UIColor.white.withAlphaComponent(0.14))
        }
        
    }
    
    func showInfo() {
        if storage.schedule.courses.isEmpty {
            infoLabel.setText("Loading classes from iPhone...")
            infoLabel.setHidden(false)
        } else {
            if todayEvents.isEmpty {
                infoLabel.setText("No classes today.")
                infoLabel.setHidden(false)
            } else {
                infoLabel.setHidden(true)
            }
        }
        
        scheduleTable.setHidden(false)
    }
    
}

extension Int {
    
    var indexSet: IndexSet {
        return IndexSet(integer: self)
    }
    
    
}
