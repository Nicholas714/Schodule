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
    
    lazy var storage: Storage = {
        return Storage()
    }()
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    var schedules = [Schedule]()
    
    var todaySchedule: [Period] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isToday
        }).flatMap({ (schedule) -> [Period] in
            return schedule.periods
        })
    }
    
    private init() { }
    
    func getSchedulesWith(timeConstraints: [TimeConstraint]) -> [Schedule] {
        var passingSchedules = [Schedule]()
        
        for schedule in schedules {
            if Set<String>(schedule.timeConstraints.map({ (constraint) -> String in
                return constraint.getTitle()
            })).intersection(timeConstraints.map({ (constraint) -> String in
                return constraint.getTitle()
            })).count == timeConstraints.count {
                passingSchedules.append(schedule)
            }
        }
        
        return passingSchedules
    }
    
}
