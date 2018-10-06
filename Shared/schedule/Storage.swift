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
        return ["courses": appleWatchEncoded]
    }
    
    private var encoded: Data {
        let encoder = JSONEncoder()

        do {
            return try encoder.encode(schedule)
        } catch {
            fatalError("Error loading schedules.")
        }
    }
    
    private var appleWatchEncoded: Data {
        let encoder = JSONEncoder()
        
        do {
            // only send watch 1 week worth of classes
            let schedule = Schedule()
            var courses = [Course]()
            for course in self.schedule.courses {
                let newEvents = course.events.filter { $0.startDate.timeIntervalSinceNow < 604800 }
                if !newEvents.isEmpty {
                    let newCourse = Course(course: course)
                    newCourse.events = newEvents
                    courses.append(newCourse)
                }
            }
            schedule.courses = courses
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
