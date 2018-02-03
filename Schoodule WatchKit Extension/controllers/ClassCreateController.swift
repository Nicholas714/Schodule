//
//  ClassCreateController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/30/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit

class ClassCreateController: WKInterfaceController {
    
    // MARK: Properties
    
    var schoodule: Schoodule!
    var period: Period!
    var periodStartIndex: Int?
        
    // MARK: UI Outlets
    
    // pickers
    @IBOutlet var colorPicker: WKInterfacePicker!
    @IBOutlet var hourStartPicker: WKInterfacePicker!
    @IBOutlet var hourEndPicker: WKInterfacePicker!
    @IBOutlet var minuteStartPicker: WKInterfacePicker!
    @IBOutlet var minuteEndPicker: WKInterfacePicker!
    @IBOutlet var amStartPicker: WKInterfacePicker!
    @IBOutlet var amEndPicker: WKInterfacePicker!
    
    // buttons
    @IBOutlet var deleteButton: WKInterfaceButton!
    
    var isStartAM = false
    var isEndAM = false
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    func interval(of range: CountableClosedRange<Int>, for picker: WKInterfacePicker, with start: Int? = nil, formatter: NumberFormatter? = nil) {
        picker.setItems(range.map({ (number) -> WKPickerItem in
            let pickerItem = WKPickerItem()
            
            var valueString = "\(number)"
            
            if let formatter = formatter {
                valueString = formatter.string(from: NSNumber(value: number))!
            }
            
            pickerItem.caption = valueString
            pickerItem.title = valueString
            return pickerItem
        }))
        
        if let start = start {
            picker.setSelectedItemIndex(start)
        }
    }
    
    override func awake(withContext context: Any?) {
        
        if let (schoodule, period) = context as? (Schoodule, Period) { // edit passes in period
            self.schoodule = schoodule
            self.period = period
            
            setTitle("\(period.className)")
            periodStartIndex = schoodule.unsortedPeriods.index(of: period)
            
        } else if let schoodule = context as? Schoodule { // create has no period
            self.schoodule = schoodule
            deleteButton.setHidden(true)

            period = Period(className: "Class", themeIndex: Int(arc4random_uniform(UInt32(UIColor.themes.count))), start: Date(), end: Date().addingTimeInterval(40 * 60))
        }
        
        isStartAM = period.date(component: .hour, dateType: .start) < 12
        isEndAM = period.date(component: .hour, dateType: .end) < 12
    }
    
    override func didAppear() {
        populateAMPMPickers()
        populateHourPickers()
        populateMinutePickers()
        populateColorPicker()
    }
    
    // MARK: Button Actions
    
    @IBAction func save() {
        schoodule.replace(old: periodStartIndex, with: period)
        schoodule.pendingTableScrollIndex = schoodule.index(of: period)
        popToRootController()
    }
    
    @IBAction func cancel() {
        schoodule.pendingTableScrollIndex = schoodule.index(of: period)
        popToRootController()
    }
    
    @IBAction func delete() {
        schoodule.removePeriod(index: periodStartIndex)
        schoodule.pendingTableScrollIndex = schoodule.index(of: period)
        popToRootController()
    }
    
    // MARK: Picker Actions
    
    @IBAction func pickName() {
        presentTextInputController(withSuggestions: ["English", "Math", "Science", "History", "Technology", "Gym", "Language", "Lunch", "Afterschool"], allowedInputMode: .plain) { (results) in
            if let array = results, array.count > 0 {
                self.setTitle(array[0] as? String)
                self.period.className = array[0] as! String
            }
        }
    }
    
    @IBAction func pickColor(_ value: Int) {
        period.themeIndex = value
    }

    @IBAction func pickStartHour(_ value: Int) {
        if isStartAM {
            period.start = calendar.replace(componenet: .hour, with: value + 1, for: period.start)
        } else {
            period.start = calendar.replace(componenet: .hour, with: value + 13, for: period.start)
        }
    }
    
    @IBAction func pickEndHour(_ value: Int) {
        if isEndAM {
            period.end = calendar.replace(componenet: .hour, with: value + 1, for: period.end)
        } else {
            period.end = calendar.replace(componenet: .hour, with: value + 13, for: period.end)
        }
    }
    
    @IBAction func pickStartMinute(_ value: Int) {
        period.start = calendar.replace(componenet: .minute, with: value, for: period.start)
    }
    
    @IBAction func pickEndMinute(_ value: Int) {
        period.end = calendar.replace(componenet: .minute, with: value, for: period.end)
    }
    
    @IBAction func pickStartAMPM(_ value: Int) {
        if value == 0 { // am
            isStartAM = true
            period.start = period.start.addingTimeInterval(-43200) // subtract 12 hours
        } else { // pm
            isStartAM = false
            period.start = period.start.addingTimeInterval(43200) // add 12 hours
        }
    }
    
    @IBAction func pickEndAMPM(_ value: Int) {
        if value == 0 { // am
            isEndAM = true
            period.end = period.end.addingTimeInterval(-43200) // subtract 12 hours
        } else { // pm
            isEndAM = false
            period.end = period.end.addingTimeInterval(43200) // add 12 hours
        }
        
    }
    
    // MARK: Picker populators

    func populateColorPicker() {
        colorPicker.setItems(UIColor.themes.map({ (name, color) -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.caption = name
            pickerItem.title = name
            return pickerItem
        }))
        
        colorPicker.setSelectedItemIndex(period.themeIndex)
    }
    
    func populateHourPickers() {
        func setHour(for picker: WKInterfacePicker, dateType: DateType) {
            if period.date(component: .hour, dateType: dateType) > 12 {
                interval(of: (1...12), for: picker, with: period.date(component: .hour, dateType: dateType) - 13)
            } else if period.date(component: .hour, dateType: dateType) == 0 {
                interval(of: (1...12), for: picker, with: period.date(component: .hour, dateType: dateType) + 11)
            } else {
                interval(of: (1...12), for: picker, with: period.date(component: .hour, dateType: dateType) - 1)
            }
        }
        
        setHour(for: hourStartPicker, dateType: .start)
        setHour(for: hourEndPicker, dateType: .end)
    }
    
    func populateMinutePickers() {
        let numberFormatter = NumberFormatter()
        numberFormatter.paddingCharacter = "0"
        numberFormatter.paddingPosition = .beforePrefix
        numberFormatter.formatWidth = 2
        
        interval(of: (0...59), for: minuteStartPicker, with: period.date(component: .minute, dateType: .start), formatter: numberFormatter)
        interval(of: (0...59), for: minuteEndPicker, with: period.date(component: .minute, dateType: .end), formatter: numberFormatter)
    }
    
    func populateAMPMPickers() {
        func setAM(for picker: WKInterfacePicker) {
            picker.setItems(["AM", "PM"].map({ (type) -> WKPickerItem in
                let pickerItem = WKPickerItem()
                pickerItem.caption = type
                pickerItem.title = type
                return pickerItem
            }))
        }
        
        setAM(for: amStartPicker)
        setAM(for: amEndPicker)
        
        if isStartAM {
            amStartPicker.setSelectedItemIndex(0)
        } else {
            amStartPicker.setSelectedItemIndex(1)
        }
        
        if isEndAM {
            amEndPicker.setSelectedItemIndex(0)
        } else {
            amEndPicker.setSelectedItemIndex(1)
        }
    }
    
}
