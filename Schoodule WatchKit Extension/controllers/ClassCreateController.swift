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
    
    func interval(of range: CountableClosedRange<Int>, for picker: WKInterfacePicker, with start: Int) {
        picker.setItems(range.map({ (hour) -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.caption = "\(hour)"
            pickerItem.title = "\(hour)"
            return pickerItem
        }))
        
        picker.setSelectedItemIndex(start)
    }
    
    override func awake(withContext context: Any?) {
        
        if let (schoodule, period) = context as? (Schoodule, Period) { // edit passes in period
            self.schoodule = schoodule
            self.period = period
            
            setTitle("\(period.className)")
            periodStartIndex = schoodule.index(of: period)
            
        } else if let schoodule = context as? Schoodule { // create has no period
            self.schoodule = schoodule
            deleteButton.setHidden(true)
            // TODO: change start / end
            period = Period(className: "Class", themeIndex: Int(arc4random_uniform(UInt32(UIColor.themes.count))), start: Date(), end: Date())
        }
        
        populateColorPicker()
        populateHourPickers()
        populateMinutePickers()
        populateAMPMPickers()
    }
    
    // MARK: Button Actions
    
    @IBAction func save() {
        schoodule.replace(old: periodStartIndex, with: period)
        popToRootController()
    }
    
    @IBAction func cancel() {
        popToRootController()
    }
    
    @IBAction func delete() {
        schoodule.removePeriod(period)
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
        // TODO: set 0 to the hour of start/end of period
        interval(of: (1...12), for: hourStartPicker, with: 0)
        interval(of: (1...12), for: hourEndPicker, with: 0)
    }
    
    func populateMinutePickers() {
        // TODO: grab start from period date
        interval(of: (0...59), for: minuteStartPicker, with: 0)
        interval(of: (0...59), for: minuteEndPicker, with: 0)
    }
    
    func populateAMPMPickers() {
        // TODO: grab start from period date and abstract this
        func setAM(for picker: WKInterfacePicker) {
            picker.setItems([Calendar.current.amSymbol, Calendar.current.pmSymbol].map({ (type) -> WKPickerItem in
                let pickerItem = WKPickerItem()
                pickerItem.caption = type
                pickerItem.title = type
                return pickerItem
            }))
        }
        
        setAM(for: amStartPicker)
        setAM(for: amEndPicker)
    }
    
}
