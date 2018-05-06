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
        
        let day = SpecificDay(days: [.monday, .friday, .saturday])
        let alt = AlternatingEven()
        if arc4random_uniform(100) < UInt32(50) {
            let schedulesToAdd = manager.getSchedulesWith(timeConstraints: [alt])
            
            if schedulesToAdd.isEmpty {
                let schedule = Schedule()
                schedule.timeConstraints = [alt]
                schedule.append(new: period)
                manager.schedules.append(schedule)
            } else {
                for schedule in schedulesToAdd {
                    schedule.append(new: period)
                }
            }
        } else {
            let schedulesToAdd = manager.getSchedulesWith(timeConstraints: [day])
            
            if schedulesToAdd.isEmpty {
                let schedule = Schedule()
                schedule.timeConstraints = [day]
                schedule.append(new: period)
                manager.schedules.append(schedule)
            } else {
                for schedule in schedulesToAdd {
                    schedule.append(new: period)
                }
            }
        }
        
        
        
        manager.storage.saveSchedule()
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIColor.themes.count
    }
}
