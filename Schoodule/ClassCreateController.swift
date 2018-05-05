//
//  ClassCreateController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit 

class ClassCreateController: UIViewController, UIPickerViewDataSource {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var locationField: UITextField!
    @IBOutlet var startTimeSelector: UIDatePicker!
    @IBOutlet var endTimeSelector: UIDatePicker!
    @IBOutlet var colorIndexPicker: UIPickerView!
    
    var manager: SchooduleManager {
        return SchooduleManager.shared
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorIndexPicker.dataSource = self
    }
    
    @IBAction func save(_ sender: UIButton) {
        let period = Period(className: nameField.text!, themeIndex: 0, timeframe: Timeframe(start: Time(from: startTimeSelector.date), end: Time(from: endTimeSelector.date)), location: nil)
        let schedulesToAdd = manager.getSchedulesWith(timeConstraints: [TimeConstraint]())
        
        // TODO: create time constraints from data given
        
        if schedulesToAdd.isEmpty {
            let schedule = Schedule()
            // schedule.timeConstraints = [AlternatingOdd(), SpecificDay(days: [.monday])]
            schedule.append(new: period)
        } else {
            for schedule in schedulesToAdd {
                schedule.append(new: period)
            }
        }
        
        manager.storage.saveSchedule()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIColor.themes.count
    }
}
