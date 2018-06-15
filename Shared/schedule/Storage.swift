//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
// 

import Foundation

struct Storage {

    private var loadedScheduleList = ScheduleList()

    var defaults: UserDefaults

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
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        loadScheudle()
    }
    
    func saveSchedule() {
        defaults.setValue(encoded, forKey: "schedules")
    }
    
    private var encoded: Data {
        let encoder = JSONEncoder()

        do {
            return try encoder.encode(scheduleList.schedules)
        } catch {
            fatalError("Error loading schedules.")
        }
    }
    
    private mutating func loadScheudle() {
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
