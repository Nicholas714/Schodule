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
        print(scheduleList.todayCourses.count)
    }
    
    func saveSchedule() {
        defaults.setValue(encoded, forKey: "schedules")
    }
    
    var transfer: [String: Data] {
        return ["courses": encoded]
    }
    
    private var encoded: Data {
        let encoder = JSONEncoder()

        do {
            return try encoder.encode(scheduleList.schedules)
        } catch {
            fatalError("Error loading schedules.")
        }
    }
    
    func loadSchedule(data: Data) {
        loadedScheduleList.schedules.removeAll()

        let decoder = JSONDecoder()
        
        do {
            for classList in try decoder.decode([Schedule].self, from: data) {
                loadedScheduleList.schedules.append(classList)
            }
        } catch {
            fatalError("Error decoding schedules.")
        }
    }
    
    private func loadScheudle() {
        print("INITIAL LOADING")
        if let data = defaults.value(forKey: "schedules") as? Data {
            loadSchedule(data: data)
        }
    }
    
}
