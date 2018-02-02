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
    var periodStartIndex: Int!
        
    // MARK: UI Outlets
    
    @IBOutlet var deleteButton: WKInterfaceButton!
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    override func awake(withContext context: Any?) {
        if let (schoodule, period) = context as? (Schoodule, Period) {
            self.schoodule = schoodule
            self.period = period
            
            setTitle("\(period.className)")
            
            
            // if it is not in list, this is not an actual period
            if schoodule.index(of: period) == nil {
                // TODO: set period to whatever is inside the pickers by default
                periodStartIndex = 0
                deleteButton.setHidden(true)
            }
        }
    }
    
    // MARK: Button Events
    
    @IBAction func save() {
        //schoodule.replace(period: periodStartIndex, with: period)
        schoodule.addPeriod(period: period)
        popToRootController()
    }
    
    @IBAction func cancel() {
        popToRootController()
    }
    
    @IBAction func delete() {
        schoodule.removePeriod(period)
        popToRootController()
    }
    
    @IBAction func pickName() {
        presentTextInputController(withSuggestions: ["English", "Math", "Science", "History", "Technology", "Gym", "Language", "Lunch", "Afterschool"], allowedInputMode: .plain) { (results) in
            if let array = results, array.count > 0 {
                self.setTitle(array[0] as? String)
                self.period.className = array[0] as! String
            }
        }
    }
    
    
    
}
