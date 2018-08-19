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
import ColorPickerRow
import UIColor_Hex_Swift

class ClassCreateController: FormViewController {
    
    var initialSchedule: Schedule?
    var initialCourse: Course?
    
    var gradient: Gradient! {
        didSet {
            tableView.backgroundColor = gradient.darkColor.withAlphaComponent(0.9)
            navigationController?.navigationBar.barTintColor = gradient.darkColor
            navigationController?.navigationBar.isTranslucent = false 
            
            for row in form.allRows {
                row.baseCell.backgroundColor = gradient.darkColor //UIColor.white.withAlphaComponent(0.2)
            }
        }
    }
    
    private var scheduleTypes = ["Everyday", "Weekdays", "Specific Day", "Even Days", "Odd Days"]
    private var avaiableDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var scheduleNames: [String] {
        return ["New Schedule...", "Everyday"] + scheduleList.schedules.compactMap { $0.title }
    }
    
    // editable list of schedules that gets passed back to root view
    var scheduleList: ScheduleList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient = initialCourse?.gradient ?? Gradient.gradients.first!
        
        let scheduleTypeCondition = Condition.function(["schedule-type"], { form in
            return ((form.rowBy(tag: "schedule-type") as? PickerInlineRow)?.value ?? "") != "Specific Day"
        })
        let deleteRowCondition = Condition.function(["delete-course"]) { form -> Bool in
            return self.initialCourse == nil
        }
        
        form +++ Section("Course") { section in
            var header = HeaderFooterView<TextHeaderView>(.nibFile(name: "TextHeaderView", bundle: nil))
            
            header.onSetupView = { view, _ in
                view.textLabel.text = "Information"
            }
            section.header = header
            }
            <<< TextRow() { row in
                row.tag = "course-name"
                row.title = "Name"
                row.placeholder = "Course Name"
                
                if let courseName = initialCourse?.name {
                    row.value = courseName
                }
                }.cellUpdate({ (cell, row) in
                    cell.titleLabel?.textColor = .white
                    cell.textField.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< TextRow() {
                $0.tag = "course-instructor"
                $0.title = "Instructor"
                $0.placeholder = "Name"
                
                if let courseInstructor = initialCourse?.instructor {
                    $0.value = courseInstructor
                }
                }.cellUpdate({ (cell, row) in
                    cell.titleLabel?.textColor = .white
                    cell.textField.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< TextRow() {
                $0.tag = "course-location"
                $0.title = "Location"
                $0.placeholder = "Building / Room"
                
                if let courseName = initialCourse?.location {
                    $0.value = courseName
                }
                }.cellUpdate({ (cell, row) in
                    cell.titleLabel?.textColor = .white
                    cell.textField.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< TimeRow() {
                $0.tag = "start-time"
                $0.minuteInterval = 5
                $0.title = "Start Time"
                
                if let courseStartDate = initialCourse?.timeframe.start.date {
                    $0.value = courseStartDate
                } else {
                    $0.value = Date()
                }
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< TimeRow() {
                $0.tag = "end-time"
                $0.minuteInterval = 5
                $0.title = "End Time"
                
                if let courseEndDate = initialCourse?.timeframe.end.date {
                    $0.value = courseEndDate
                } else {
                    $0.value = Date().addingTimeInterval(2700)
                }
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            +++ Section("Schedule")  { section in
                var header = HeaderFooterView<TextHeaderView>(.nibFile(name: "TextHeaderView", bundle: nil))
                
                header.onSetupView = { view, _ in
                    view.textLabel.text = "Schedule"
                }
                
                section.header = header
            }
            <<< PickerInlineRow<String>() {
                $0.tag = "schedule-type"
                $0.title = "Type"
                $0.options = scheduleTypes
                
                if let scheduleType = initialSchedule?.scheduleType {
                    $0.value = scheduleType.title
                    if let type = scheduleType as? SpecificDay {
                        if type.title != "Weekdays" {
                            $0.value = "Specific Day"
                        }
                    }
                }
                
                }.onExpandInlineRow({ (cell, inlineRow, pickerRow) in
                    pickerRow.baseCell.backgroundColor = self.gradient.darkColor
                }).cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                    cell.tintColor = UIColor.white.withAlphaComponent(0.7)
                })
            
            <<< MultipleSelectorRow<String>() {
                $0.title = "Days"
                $0.options = avaiableDays
                if let specificDay = initialSchedule?.scheduleType as? SpecificDay {
                    $0.value = Set([specificDay.day.shortName])
                } else {
                    $0.value = Set(Day.weekdays.map { $0.shortName })
                }
                
                $0.tag = "segmented-days"
                $0.hidden = scheduleTypeCondition
                
                }.cellUpdate({ (cell, row) in
                    cell.tintColor = .white
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< DateRow() {
                $0.tag = "start-date"
                $0.title = "Start Date"
                
                if let scheduleStartDate = initialSchedule?.term.start {
                    $0.value = scheduleStartDate
                } else {
                    $0.value = Date()
                }
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< DateRow() {
                $0.tag = "end-date"
                $0.title = "End Date"
                $0.value = Date()
                
                if let scheduleEndDate = initialSchedule?.term.end {
                    $0.value = scheduleEndDate
                } else {
                    $0.value = nil
                }
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
                })
            <<< ColorPickerRow("colors") { (row) in
                row.title = "Pick Color"
                row.isCircular = true
                row.showsCurrentSwatch = true
                row.showsPaletteNames = false
                row.value = gradient.darkColor
                }
                .cellSetup { (cell, row) in
                    cell.palettes = [ColorPalette(name: "All", palette: Gradient.gradients.map { ColorSpec(hex: $0.darkColor.hexString(), name: "") })]
                    
                }.onChange({ (picker) in
                    guard let newDarkColor = picker.value else {
                        return
                    }
                    
                    for grad in Gradient.gradients {
                        if grad.darkColor == newDarkColor {
                            self.gradient = grad
                        }
                    }
                })
            <<< ButtonRow() { (row) in
                row.title = "Delete"
                row.value = "Delete"
                row.hidden = deleteRowCondition
                
                }.onCellSelection({ (cell, row) in
                    print("DELETE")
                    self.delete()
                })
        
        self.view.backgroundColor = .white
        tableView.separatorColor = .clear

        for row in form.allRows {
            row.baseCell.backgroundColor = gradient.darkColor
            
            for view in row.baseCell.contentView.subviews {
                if let label = view as? UILabel {
                    label.textColor = .white
                }
                if let textField = view as? UITextField {
                    textField.textColor = .white
                }
            }
        }
        
        
    }
    
    func presentMissingInfoAlert(input: String) {
        let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance())
        alertView.showError("Missing Information", subTitle: "Please input the \(input).")
    }
    
    @IBAction func save(_ sender: UIButton) {
        save()
    }
    
    func delete() {
        let scheduleType: ScheduleType
        let term: Term
        
        // remove oldSchedule and replace with same schedule but without the initial course
        if var oldSchedule = self.initialSchedule, let index = scheduleList.schedules.firstIndex(of: oldSchedule) {
            oldSchedule.classList.remove(element: initialCourse)
            scheduleList.schedules[index] = oldSchedule
            
            scheduleType = oldSchedule.scheduleType
            term = oldSchedule.term
        } else {
            preconditionFailure("Schedule not found.")
        }
        
        var newSchedule: Schedule
        if let foundSchedule = scheduleList.getScheduleWith(scheduleType: scheduleType, term: term) {
            // if found, remove from scheduleList to be replaced with new one
            scheduleList.schedules.remove(element: foundSchedule)
            newSchedule = foundSchedule
        } else {
            newSchedule = Schedule(scheduleType: scheduleType, term: term)
        }
        
        if let schedule = initialSchedule, schedule.classList.count == 1 {
            scheduleList.schedules.remove(element: initialSchedule)
        }
        
        if !newSchedule.classList.isEmpty {
            scheduleList.schedules.append(newSchedule)
        }
        
        if let root = navigationController?.viewControllers.first as? MainTableViewController {
            root.storage.scheduleList = scheduleList
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func save() {
        let handler = ScheduleFormHandler(form: form)
        handler.handleSave()
        
        if !handler.canSave {
            return
        }
        
        let courseNameRow: TextRow = form.rowBy(tag: "course-name")!
        let instructorRow: TextRow = form.rowBy(tag: "course-instructor")!
        let locationRow: TextRow = form.rowBy(tag: "course-location")!
        let startTimeRow: TimeRow = form.rowBy(tag: "start-time")!
        let endTimeRow: TimeRow = form.rowBy(tag: "end-time")!
        let scheduleTypeRow: PickerInlineRow<String> = form.rowBy(tag: "schedule-type")!
        let startDateRow: DateRow = form.rowBy(tag: "start-date")!
        let endDateRow: DateRow = form.rowBy(tag: "end-date")!
        let specificDaysPicker: MultipleSelectorRow<String> = form.rowBy(tag: "segmented-days")!
        
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
        let course = Course(name: courseName, gradient: gradient, timeframe: timeframe, teacher: instructorRow.value, location: locationRow.value)
        let term = Term(start: startDateRow.value!, end: endDateRow.value)
        
        guard var scheduleType = SpecificDay.scheduleFromValue(scheduleTypeRow.value!, startDateRow.value) else {
            return
        }
        
        if scheduleType is SpecificDay, let rawDays = specificDaysPicker.value {
            let days = Day.everyday.filter { rawDays.contains($0.shortName) }
            
            for scheduleType in days.map({ SpecificDay(day: $0) }) {
                var newSchedule: Schedule
                if let foundSchedule = scheduleList.getScheduleWith(scheduleType: scheduleType, term: term) {
                    // if found, remove from scheduleList to be replaced with new one
                    scheduleList.schedules.remove(element: foundSchedule)
                    newSchedule = foundSchedule
                } else {
                    newSchedule = Schedule(scheduleType: scheduleType, term: term)
                }
                
                if let schedule = initialSchedule, schedule.classList.count == 1 {
                    scheduleList.schedules.remove(element: initialSchedule)
                }
                
                newSchedule.classList.append(course)
                scheduleList.schedules.append(newSchedule)
            }
            if let root = navigationController?.viewControllers.first as? MainTableViewController {
                root.storage.scheduleList = scheduleList
            }
            
            navigationController?.popViewController(animated: true)
            
            return
        }
        
        // remove oldSchedule and replace with same schedule but without the initial course
        if var oldSchedule = self.initialSchedule, let index = scheduleList.schedules.firstIndex(of: oldSchedule) {
            oldSchedule.classList.remove(element: initialCourse)
            scheduleList.schedules[index] = oldSchedule
        }
        
        var newSchedule: Schedule
        if let foundSchedule = scheduleList.getScheduleWith(scheduleType: scheduleType, term: term) {
            // if found, remove from scheduleList to be replaced with new one
            scheduleList.schedules.remove(element: foundSchedule)
            newSchedule = foundSchedule
        } else {
            newSchedule = Schedule(scheduleType: scheduleType, term: term)
        }
        
        if let schedule = initialSchedule, schedule.classList.count == 1 {
            scheduleList.schedules.remove(element: initialSchedule)
        }
        
        newSchedule.classList.append(course)
        scheduleList.schedules.append(newSchedule)
        
        if let root = navigationController?.viewControllers.first as? MainTableViewController {
            root.storage.scheduleList = scheduleList
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}


