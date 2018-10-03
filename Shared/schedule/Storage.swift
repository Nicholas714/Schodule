//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
// 

import Foundation

class Storage: Equatable {
    
    static func == (lhs: Storage, rhs: Storage) -> Bool {
        return lhs.loadedSchedule == rhs.loadedSchedule
    }
    
    private var loadedSchedule = Schedule()

    var defaults: UserDefaults

    var schedule: Schedule {
        get {
            return loadedSchedule
        }
        set {
            loadedSchedule = newValue
            print("schedule has been set")
            saveSchedule()
        }
    }
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        loadScheudle()
    }
    
    func saveSchedule() {
        defaults.setValue(encoded, forKey: "schedule")
    }
    
    var transfer: [String: Data] {
        return ["courses": encoded]
    }
    
    private var encoded: Data {
        let encoder = JSONEncoder()

        do {
            return try encoder.encode(schedule)
        } catch {
            fatalError("Error loading schedules.")
        }
    }
    
    func loadSchedule(data: Data) {
        let decoder = JSONDecoder()

        if let schedule = try? decoder.decode(Schedule.self, from: data) {
            self.schedule = schedule
        } else {
            print("none.")
        }
    }
    
    private func loadScheudle() {
        print("INITIAL LOADING")
        if let data = defaults.value(forKey: "schedule") as? Data {
            loadSchedule(data: data)
        }
    }
    
    
    
}
