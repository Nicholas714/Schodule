//
//  ColorGenerator.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class ColorGenerator {

    var red: CGFloat = 219 / 255
    var green: CGFloat = 46 / 255
    var blue: CGFloat = 32 / 255
    
    var currentColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func nextColor() {
        red = incrementColor(color: red, amount: 0.08)
        green = incrementColor(color: green, amount: -30 / 255)
        blue = incrementColor(color: blue, amount: 75 / 255)
    }
    
    func incrementColor(color: CGFloat, amount: CGFloat) -> CGFloat {
        let newValue = color + amount
        
        if newValue <= 0.1 || newValue > 1.0 {
            if (amount < 0) {
                return 1.0
            }
            return 0.3
        } else {
            return newValue
        }
    }
    
}
