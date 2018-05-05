//
//  SchooduleManager.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import WatchConnectivity

class SchooduleManager {
    
    static var shared = SchooduleManager()
    
    let schoodule = Schoodule()
    
    private init() { }
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    var schedules = [Schedule]()
    
    var todaySchedule: [Schedule] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isToday
        })
    }
    
    func saveSchedule() {
        defaults.setValue(schoodule.storage.encoded, forKey: "periods")
    }
    
    func loadScheudle() {
        schoodule.unsortedPeriods.removeAll()
        
        if let data = defaults.value(forKey: "periods") as? Data {
            let decoder = JSONDecoder()
            
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    schoodule.unsortedPeriods.insert(period)
                }
                schoodule.periods = schoodule.unsortedPeriods.sorted()
            } catch {
                fatalError("Error decoding periods.")
            }
        }
    }
    
}
