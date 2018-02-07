//
//  TimePicker.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/6/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class TimePicker: UIDatePicker {
    
    override func awakeFromNib() {
        setValue(UIColor.white, forKey: "textColor")
    }
    
}
