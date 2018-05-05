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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorIndexPicker.dataSource = self
    }
    
    @IBAction func save(_ sender: UIButton) {
        let newPeriod = Period(className: nameField.text!, themeIndex: 0, start: Time(from: startTimeSelector.date), end: Time(from: endTimeSelector.date))
        SchooduleManager.shared.schoodule.replace(old: nil, with: newPeriod)
        SchooduleManager.shared.saveSchedule()
        print(SchooduleManager.shared.schoodule.unsortedPeriods.count)
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIColor.themes.count
    }
}
