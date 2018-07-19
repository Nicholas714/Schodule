//
//  ClassCreateController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import Eureka

class ClassCreateController: UIViewController {
    
    @IBOutlet var nameField: UITextField!
    
    // schedule and course being made from the controller
    var schedule: Schedule?
    var course: Course?
    
    // editable list of schedules that gets passed back to root view
    var scheduleList: ScheduleList!
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let timeframe = Timeframe(start: Time(0, 30, true), end: Time(22, 00, true))
        let course = Course(name: nameField.text!, themeIndex: 0, timeframe: timeframe, location: nil)
        
        let term: TimeConstraint
        if course.name == "English" {
            term = SpecificDay(days: [.monday, .wednesday])
        } else if course.name == "Physics" || course.name == "Calculus" || course.name == "Spanish" {
            term = SpecificDay(days: [.tuesday, .friday])
        } else if course.name == "Lunch" || course.name == "Statistics" {
            term = SpecificDay(days: Day.everyday)
        } else {
            term = SpecificDay(days: [.thursday])
        }
        
        let sameSchedule = scheduleList.getScheduleWith(timeConstraints: [term])
        
        var schedule: Schedule
        
        if let sch = sameSchedule {
            schedule = sch
        } else {
            schedule = Schedule()
            schedule.setConstraints([term])
            scheduleList.schedules.append(schedule)
        }
        schedule.classList.append(course)
        
        if let root = navigationController?.viewControllers[0] as? MainTableViewController {
            root.storage.scheduleList = scheduleList
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}
