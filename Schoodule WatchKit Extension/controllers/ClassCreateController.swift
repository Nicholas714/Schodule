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
    var initialPeriod: Period?

    // MARK: UI Outlets
    
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    
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
    
    func interval(of range: [Int], for picker: WKInterfacePicker, with start: Int? = nil, formatter: NumberFormatter? = nil) {
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
        
        if let (s, period) = context as? (Schoodule, Period) { // edit passes in period
            self.schoodule = s
            self.period = period

            initialPeriod = period
        } else if let schoodule = context as? Schoodule { // create has no period
            self.schoodule = schoodule
            deleteButton.setHidden(true)

            // auto calculate next start and next end
            if let lastPeriod = schoodule.lastPeriod {
                let newStart = lastPeriod.end.date.addingTimeInterval(300)
                period = Period(className: "Class", themeIndex: Int(arc4random_uniform(UInt32(UIColor.themes.count))), start: Time(from: newStart), end: Time(from: newStart.addingTimeInterval(40 * 60)))
            } else {
                period = Period(className: "Class", themeIndex: Int(arc4random_uniform(UInt32(UIColor.themes.count))), start: Time(from: Date()), end: Time(from: Date().addingTimeInterval(40 * 60)))
            }
        }
        
        nameLabel.setText(period.className)
        locationLabel.setText(period.location ?? "Location")
    }
    
    override func willActivate() {
        DispatchQueue.main.async {
            self.populateMinutePickers()
            self.populateHourPickers()
            self.populateAMPMPickers()
            self.populateColorPicker()
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func save() {
        if period.start.date > period.end.date {
            let okAlert = WKAlertAction(title: "Ok", style: .default) {
                self.scroll(to: self.amStartPicker, at: .top, animated: true)
            }
            self.presentAlert(withTitle: "Time Error", message: "Start time must be before end time.", preferredStyle: .alert, actions: [okAlert])
        } else {
            schoodule.replace(old: initialPeriod, with: period)
            schoodule.pendingTableScrollIndex = schoodule.index(of: period)
            popToRootController()
        }
    }
    
    @IBAction func delete() {
        let deleteConfirm = WKAlertAction(title: "Delete", style: .destructive) {
            self.schoodule.remove(old: self.initialPeriod)
            self.schoodule.pendingTableScrollIndex = self.schoodule.index(of: self.period)
            
            DispatchQueue.main.async {
                self.popToRootController()
            }
        }
        self.presentAlert(withTitle: "Delete \"\(period.className)\"", message: "This action cannot be undone.", preferredStyle: .actionSheet, actions: [deleteConfirm])
    }
    
    
    
    // MARK: Picker Actions
    
    @IBAction func pickName() {
        presentTextInputController(withSuggestions: ["English", "Math", "Science", "History", "Technology", "Gym", "Language", "Lunch", "Afterschool"], allowedInputMode: .plain) { (results) in
            if let array = results, array.count > 0 {
                self.nameLabel.setText(array[0] as? String)
                self.period.className = array[0] as! String
            }
        }
    }
    
    @IBAction func pickLocation() {
        presentTextInputController(withSuggestions: ["Library", "Cafeteria", "Gymnasium", "Computer Lab", "None"], allowedInputMode: .plain) { (results) in
            if let array = results, array.count > 0 {
                if let location = array[0] as? String {
                    if location == "None" {
                        self.locationLabel.setText("Location")
                        self.period.location = nil
                    } else {
                        self.locationLabel.setText(location)
                        self.period.location = location
                    }
                }
            }
        }
    }
    @IBAction func pickColor(_ value: Int) {
        period.themeIndex = value
    }

    @IBAction func pickStartHour(_ value: Int) {
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
        period.start.minute = value * 5
    }
    
    @IBAction func pickEndMinute(_ value: Int) {
        period.end.minute = value * 5
    }
    
    @IBAction func pickStartAMPM(_ value: Int) {
        period.start.isAM = value == 0
    }
    
    @IBAction func pickEndAMPM(_ value: Int) {
        period.end.isAM = value == 0
    }
    
    // MARK: Picker populators

    func populateColorPicker() {
        func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
        
        colorPicker.setItems(UIColor.themes.map({ (name, color) -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.caption = name
            let width = WKInterfaceDevice.current().screenBounds.width
            pickerItem.contentImage = WKImage(image: getImageWithColor(color: color, size: CGSize(width: width, height: 25)))
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
        
        interval(of: (1...12).sorted(), for: hourStartPicker)
        interval(of: (1...12).sorted(), for: hourEndPicker)
        
        hourStartPicker.setSelectedItemIndex(indexHour(for: period.start.hour))
        hourEndPicker.setSelectedItemIndex(indexHour(for: period.end.hour))
    }
    
    func populateMinutePickers() {
        let numberFormatter = NumberFormatter()
        numberFormatter.paddingCharacter = "0"
        numberFormatter.paddingPosition = .beforePrefix
        numberFormatter.formatWidth = 2
        
        
        interval(of: stride(from: 0, through: 55, by: 5).sorted(), for: minuteStartPicker, with: period.start.minute / 5, formatter: numberFormatter)
        interval(of: stride(from: 0, through: 55, by: 5).sorted(), for: minuteEndPicker, with: period.end.minute / 5, formatter: numberFormatter)
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
