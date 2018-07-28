//
//  ClassCreateController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView

class ClassCreateController: FormViewController {
    
    // schedule and couOrse being made from the controller
    var schedule: Schedule?
    var course: Course?
    
    private var scheduleTypes = ["Everyday", "Weekdays", "Weekends", "Specific Day", "Alternating Even", "Alternating Odd"]
    private var avaiableDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // editable list of schedules that gets passed back to root view
    var scheduleList: ScheduleList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Course")
            <<< TextRow() { row in
                row.tag = "name"
                row.title = "Name"
                row.placeholder = "Physics"
                row.add(rule: RuleEmail())
                if let courseName = course?.name {
                    row.value = courseName
                }
            }
            <<< TextRow() {
                $0.tag = "location"
                $0.title = "Location"
                $0.placeholder = "Room 102"
                
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
                    $0.value = Date()
                }
            }
            <<< TimeInlineRow() {
                $0.tag = "end-time"
                $0.minuteInterval = 5
                $0.title = "End Time"
                
                if let courseEndDate = course?.timeframe.end.date {
                    $0.value = courseEndDate
                } else {
                    $0.value = Date().addingTimeInterval(2700)
                }
            }
            +++ Section("Schedule")
            <<< PickerInlineRow<String>() {
                $0.tag = "schedule-type"
                $0.title = "Schedule Type"
                $0.options = scheduleTypes
                
                if let scheduleType = schedule?.scheduleType {
                    $0.value = scheduleType.title
                }
            }
            <<< SegmentedRow<String>() {
                $0.options = avaiableDays
                $0.value = "Mon"
                $0.tag = "segmented-days"
                $0.hidden = Condition.function(["schedule-type"], { form in
                    return ((form.rowBy(tag: "schedule-type") as? PickerInlineRow)?.value ?? "") != "Specific Day"
                })
            }
            <<< DateInlineRow() {
                $0.tag = "start-date"
                $0.title = "Start Date"
                
                if let scheduleStartDate = schedule?.term.start {
                    $0.value = scheduleStartDate
                } else {
                    $0.value = Date()
                }
            }
            <<< DateInlineRow() {
                $0.tag = "end-date"
                $0.title = "End Date"
                $0.value = Date()
                
                if let scheduleEndDate = schedule?.term.end {
                    $0.value = scheduleEndDate
                } else {
                    $0.value = Date()
                }
            }
    }
    
    func presentMissingInfoAlert(input: String) {
        let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance())
        alertView.showError("Missing Information", subTitle: "Please input the \(input).")
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let courseNameRow: TextRow = form.rowBy(tag: "name")!
        let locationRow: TextRow = form.rowBy(tag: "location")!
        let startTimeRow: TimeInlineRow = form.rowBy(tag: "start-time")!
        let endTimeRow: TimeInlineRow = form.rowBy(tag: "end-time")!
        let startDateRow: DateInlineRow = form.rowBy(tag: "start-date")!
        let endDateRow: DateInlineRow = form.rowBy(tag: "end-date")!
        let scheduleTypeRow: PickerInlineRow<String> = form.rowBy(tag: "schedule-type")!
        let specificDaysPicker: SegmentedRow<String> = form.rowBy(tag: "segmented-days")!
        
        // TODO: make sure name, location, starttime and end time values are not nil & custom alert view
        guard let courseName = courseNameRow.value else {
            presentMissingInfoAlert(input: "course name")
            return
        }
        guard let scheduleTypeString = scheduleTypeRow.value else {
            presentMissingInfoAlert(input: "schedule type")
            return
        }
        
        let timeframe = Timeframe(start: Time(from: startTimeRow.value!), end: Time(from: endTimeRow.value!))
        let course = Course(name: courseName, themeIndex: 0, timeframe: timeframe, location: locationRow.value)
        let term = Term(start: startDateRow.value!, end: endDateRow.value!)
        
        let scheduleType: ScheduleType
        switch scheduleTypeString {
        case "Everyday":
            scheduleType = SpecificDay(days: Day.everyday)
        case "Weekdays":
            scheduleType = SpecificDay(days: Day.weekdays)
        case "Weekends":
            scheduleType = SpecificDay(days: Day.weekends)
        case "Alternating Even":
            scheduleType = AlternatingEven(startDate: startDateRow.value!)
        case "Alternating Odd":
            scheduleType = AlternatingOdd(startDate: startDateRow.value!)
        case "Specific Day":
            scheduleType = SpecificDay(days: [.monday])
        default:
            return
        }
        
        var newSchedule = scheduleList.getScheduleWith(scheduleType: scheduleType, term: term) ?? Schedule(scheduleType: scheduleType, term: term)
        if let oldSchedule = self.schedule {
            newSchedule.classList = oldSchedule.classList
            if let removeIndex = scheduleList.schedules.firstIndex(of: oldSchedule) {
                scheduleList.schedules.remove(at: removeIndex)
            }
        }
        if let course = self.course, let removeIndex = schedule?.classList.firstIndex(of: course) {
            schedule?.classList.remove(at: removeIndex)
        }
        
        newSchedule.classList.append(course)
        scheduleList.schedules.append(newSchedule)
        
        if let root = navigationController?.viewControllers[0] as? MainTableViewController {
            root.storage.scheduleList = scheduleList
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}

