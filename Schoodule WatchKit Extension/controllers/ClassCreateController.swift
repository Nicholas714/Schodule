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
    
    var calendar: Calendar {
        return Calendar.current
    }

    var isLock = true
    
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
        
            periodStartIndex = schoodule.unsortedPeriods.index(of: period)
            
        } else if let schoodule = context as? Schoodule { // create has no period
            self.schoodule = schoodule
            deleteButton.setHidden(true)

            period = Period(className: "Class", themeIndex: Int(arc4random_uniform(UInt32(UIColor.themes.count))), start: Time(from: Date()), end: Time(from: Date().addingTimeInterval(40 * 60)))
        }
        
        setTitle("\(period.className)")
    }
    
    override func willActivate() {
        DispatchQueue.main.async {
            self.populateMinutePickers()
            self.populateHourPickers()
            self.populateAMPMPickers()
            self.populateColorPicker()
            self.isLock = false
        }
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
        if isLock {
            return
        }
        
        period.themeIndex = value
    }

    @IBAction func pickStartHour(_ value: Int) {
        if isLock {
            return
        }
        
        if value == 11 {
            if period.start.isAM {
                period.start.hour = 0
            } else {
                period.start.hour = 12
            }
        } else {
            if period.start.isAM {
                period.start.hour = value + 1
            } else {
                period.start.hour = value + 13
            }
        }
        
    }
    
    @IBAction func pickEndHour(_ value: Int) {
        if isLock {
            return
        }
        
        if value == 11 {
            if period.end.isAM {
                period.end.hour = 0
            } else {
                period.end.hour = 12
            }
        } else {
            if period.end.isAM {
                period.end.hour = value + 1
            } else {
                period.end.hour = value + 13
            }
        }
    }
    
    @IBAction func pickStartMinute(_ value: Int) {
        if isLock {
            return
        }
        
        period.start.minute = value
    }
    
    @IBAction func pickEndMinute(_ value: Int) {
        if isLock {
            return
        }
        
        period.end.minute = value
    }
    
    @IBAction func pickStartAMPM(_ value: Int) {
        if isLock {
            return
        }
    
        period.start.isAM = value == 0
    }
    
    @IBAction func pickEndAMPM(_ value: Int) {
        if isLock {
            return
        }
        
        period.end.isAM = value == 0
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
        func indexHour(for hour: Int) -> Int {
            switch hour {
            case 1...11: // 1-11 (1AM-11AM), subtract 1 to bring from hour to index scale
                return hour - 1
            case 13...23: // 13-23 (1PM-11PM), subtract 12 to bring it to 0-11 scale
                return hour - 13
            case 0: // 0 (12AM) or 12 (12PM), make it go to max index (11)
                fallthrough
            case 12:
                return 11
            default:
                return 0
            }
        }
        
        interval(of: (1...12), for: hourStartPicker)
        interval(of: (1...12), for: hourEndPicker)
        
        hourStartPicker.setSelectedItemIndex(indexHour(for: period.start.hour))
        hourEndPicker.setSelectedItemIndex(indexHour(for: period.end.hour))
    }
    
    func populateMinutePickers() {
        let numberFormatter = NumberFormatter()
        numberFormatter.paddingCharacter = "0"
        numberFormatter.paddingPosition = .beforePrefix
        numberFormatter.formatWidth = 2
        
        interval(of: (0...59), for: minuteStartPicker, with: period.start.minute, formatter: numberFormatter)
        interval(of: (0...59), for: minuteEndPicker, with: period.end.minute, formatter: numberFormatter)
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
        
        amStartPicker.setSelectedItemIndex((!period.start.isAM).hashValue)
        amEndPicker.setSelectedItemIndex((!period.end.isAM).hashValue)
    }
    
}
