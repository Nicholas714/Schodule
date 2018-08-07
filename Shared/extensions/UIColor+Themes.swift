//
//  UIColor+Themes.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let themes = [
    "Red": UIColor(red: 202/255.0, green: 63/255.0, blue: 46/255.0, alpha: 1.0),
    "Orange": UIColor(red: 0.960668, green: 0.306238, blue: 0.0611271, alpha: 1.0),
    "Yellow": UIColor(red: 216/255.0, green: 195/255.0, blue: 64/255.0, alpha: 1.0),
    "Green": UIColor(red: 122/255.0, green: 192/255.0, blue: 93/255.0, alpha: 1.0),
    "Blue": UIColor(red: 0.326728, green: 0.525373, blue: 0.971058, alpha: 1.0),
    "Teal": UIColor(red: 0.15546, green: 0.828514, blue: 0.798872, alpha: 1.0),
    "Purple": UIColor(red: 0.524457, green: 0.373256, blue: 0.61088, alpha: 1.0),
    "Violet": UIColor(red: 0.668182, green: 0.30604, blue: 0.754354, alpha: 1.0),
    "Pink": UIColor(red: 0.822419, green: 0.134234, blue: 0.549453, alpha: 1.0),
    "Brown": UIColor(red: 118/255.0, green: 91/255.0, blue: 64/255.0, alpha: 1.0)
    ]
    
    
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
}
