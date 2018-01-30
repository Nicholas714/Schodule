//
//  ClassEditController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/29/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit

class ClassEditController: WKInterfaceController {
    
    var period: Period! = nil
    
    override func awake(withContext context: Any?) {
        period = context as! Period
        setTitle("\(period.className)")
    }
    
    @IBAction func editClassName() {
        presentTextInputController(withSuggestions: ["English", "Math", "History", "Gym"], allowedInputMode: .plain) { (results) in
            if let array = results {
                print(array[0])
            }
        }
    }
}
