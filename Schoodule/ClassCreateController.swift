//
//  ClassCreateController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import Eureka

class ClassCreateController: FormViewController {
    
    // schedule and course being made from the controller
    var schedule: Schedule?
    var course: Course?
    
    private var scheduleTypes = ["Everyday", "Weekdays", "Weekends", "Specific Day", "Alternating Even", "Alternating Odd"]

    // editable list of schedules that gets passed back to root view
    var scheduleList: ScheduleList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Course")
            <<< TextRow() { row in
                row.tag = "name"
                row.title = "Name"
                row.placeholder = "Enter name here"
                
                if let courseName = course?.name {
                    row.value = courseName
                }
            }
            <<< TextRow() {
                $0.tag = "location"
                $0.title = "Location"
                $0.placeholder = "Enter location here"
                
                if let courseName = course?.location {
                    $0.value = courseName
                }
            }
            <<< TimeInlineRow() {
                $0.tag = "start-time"
                $0.minuteInterval = 5
                $0.title = "Start Time"
                
                if let courseStartDate = course?.timeframe.start.date {
                    $0.value = courseStartDate
                } else {
                    $0.value = Date(timeIntervalSinceReferenceDate: 0)
                }
            }
            <<< TimeInlineRow() {
                $0.tag = "end-time"
                $0.title = "End Time"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("Schedule")
            <<< DateInlineRow() {
                $0.tag = "start-date"
                $0.title = "Start Date"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< DateInlineRow() {
                $0.tag = "end-date"
                $0.title = "End Date"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< PickerInlineRow<String>() {
                $0.tag = "schedule-type"
                $0.title = "Schedule Type"
                $0.options = scheduleTypes
            }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let courseNameRow: TextRow = form.rowBy(tag: "name")!
        let locationRow: TextRow = form.rowBy(tag: "location")!
        let startTimeRow: TimeInlineRow = form.rowBy(tag: "start-time")!
        let endTimeRow: TimeInlineRow = form.rowBy(tag: "end-time")!
        let startDateRow: DateInlineRow = form.rowBy(tag: "start-date")!
        let endDateRow: DateInlineRow = form.rowBy(tag: "end-date")!
        let scheduleTypeRow: PickerInlineRow<String> = form.rowBy(tag: "schedule-type")!
        
        let timeframe = Timeframe(start: Time(from: startTimeRow.value!), end: Time(from: endTimeRow.value!))
        let course = Course(name: courseNameRow.value!, themeIndex: 0, timeframe: timeframe, location: locationRow.value)
        
        let term: TimeConstraint
        switch scheduleTypeRow.value! {
        case "Everyday":
            term = SpecificDay(days: Day.everyday)
        case "Weekdays":
            term = SpecificDay(days: Day.weekdays)
        case "Weekends":
            term = SpecificDay(days: Day.weekends)
        case "Alternating Even":
            term = AlternatingEven(startDate: startDateRow.value!)
        case "Alternating Odd":
            term = AlternatingOdd(startDate: startDateRow.value!)
        case "Specific Day":
            term = SpecificDay(days: [.monday])
        default:
            return
        }
        
        let sameSchedule = scheduleList.getScheduleWith(timeConstraints: [term])
        
        var schedule: Schedule
        
        if let sch = sameSchedule {
            schedule = sch
        } else {
            schedule = Schedule()
            schedule.term = Term(start: startDateRow.value!, end: endDateRow.value)
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
