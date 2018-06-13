//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
// 

import Foundation

class Storage {
    
    private var loadedScheduleList = ScheduleList()
    
    var scheduleList: ScheduleList {
        get {
            return loadedScheduleList
        }
        set {
            loadedScheduleList = newValue
            print("schedule has been set")
            saveSchedule()
        }
    }
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    var encoded: Data {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(scheduleList.schedules)
        } catch {
            fatalError("Error loading schedules.")
        }
    }

    func saveSchedule() {
        defaults.setValue(encoded, forKey: "schedules")
    }
    
    func loadScheudle() {
        loadedScheduleList.schedules.removeAll()
        
        if let data = defaults.value(forKey: "schedules") as? Data {
            let decoder = JSONDecoder()

            do {
                for classList in try decoder.decode([Schedule].self, from: data) {
                    loadedScheduleList.schedules.append(classList)
                }
            } catch {
                fatalError("Error decoding schedules.")
            }
        }
    }
    
}
