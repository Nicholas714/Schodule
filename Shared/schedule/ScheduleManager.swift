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
    
    var todaySchedule: [Schedule] {
        return schedules.filter({ (schedule) -> Bool in
            return schedule.isToday
        })
    }
    
    var scheduleStatus: ScheduleStatus {
        if schedules.isEmpty && todaySchedule.isEmpty { // completely empty
            return .empty
        } else if todaySchedule.isEmpty && !schedules.isEmpty { // nothing today but there are schedules
            return .schedules
        }
        return .both
    }
    
    private init() { }
    
    func getSchedulesWith(timeConstraints: [TimeConstraint]) -> [Schedule] {
        var passingSchedules = [Schedule]()
        
        //for schedule in schedules {
           // for scheduleTimeConstraint in schedule.timeConstraints {
                //if !timeConstraints.contains(scheduleTimeConstraint) {
                //    break
                //}
            //}
            //passingSchedules.append(schedule)
        //}
        return passingSchedules
    }
    
}
