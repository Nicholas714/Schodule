//
//  ClassCreateController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/30/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit

class ClassCreateController: WKInterfaceController {

    @IBOutlet var classSeperator: WKInterfaceSeparator!
    @IBOutlet var currentName: WKInterfaceLabel!
    @IBOutlet var colorPicker: WKInterfacePicker!
    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var minutePicker: WKInterfacePicker!
    @IBOutlet var noonPicker: WKInterfacePicker!
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    override func awake(withContext context: Any?) {
        let items = ["Red", "Green", "Blue", "Orange", "Purple"].map { (name) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = name
            return item
        }
        
        let hours = (1...12).map { (num) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = "\(num)"
            return item
        }
        
        let min = (0...59).map { (num) -> WKPickerItem in
            let numberFormatter = NumberFormatter()
            numberFormatter.paddingCharacter = "0"
            numberFormatter.paddingPosition = .beforePrefix
            numberFormatter.formatWidth = 2
            
            let item = WKPickerItem()
            item.title = numberFormatter.string(from: NSNumber(value: num))
            return item
        }
        
        let zones = [calendar.amSymbol, calendar.pmSymbol].map { (noon) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = noon
            return item
        }
        
        noonPicker.setItems(zones)
        hourPicker.setItems(hours)
        minutePicker.setItems(min)
        colorPicker.setItems(items)
        
        if let period = context as? Period {
            setTitle("\(period.className)")
            
            let hourIndexStart = calendar.component(.hour, from: period.start) - 1
            let minIndexStart = calendar.component(.minute, from: period.start)
            
            hourPicker.setSelectedItemIndex(hourIndexStart)
            minutePicker.setSelectedItemIndex(minIndexStart)
        }
    }
    
    @IBAction func pickColor(_ value: Int) {
        let colors: [UIColor] = [.red, .green, .blue, .orange, .purple]
        classSeperator.setColor(colors[value])
        currentName.setTextColor(colors[value])
    }
    
    @IBAction func pickName() {
        presentTextInputController(withSuggestions: ["English", "Math", "History", "Gym"], allowedInputMode: .plain) { (results) in
            if let array = results, array.count > 0 {
                self.setTitle(array[0] as? String)
            }
        }
    }
    
}
