//
//  Gradient.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

struct Gradient: Codable, Equatable {
    
    static func == (lhs: Gradient, rhs: Gradient) -> Bool {
        return lhs.darkColor == rhs.darkColor && lhs.lightColor == rhs.lightColor
    }
    
    static var gradients: [Gradient] = [.red, .purple, .pink, .green, .blue, .orange]
    
    static var orange = Gradient(dark: Color(red: 233/255.0, green: 62/255.0, blue: 37/255.0, alpha: 1.0), light: Color(red: 237/255.0, green: 131/255.0, blue: 50/255.0, alpha: 1.0))
    static var blue = Gradient(dark: Color(red: 18/255.0, green: 58/255.0, blue: 123/255.0, alpha: 1.0), light: Color(red: 106/255.0, green: 168/255.0, blue: 240/255.0, alpha: 1.0))
    static var green = Gradient(dark: Color(red: 109/255.0, green: 169/255.0, blue: 68/255.0, alpha: 1.0), light: Color(red: 178/255.0, green: 220/255.0, blue: 115/255.0, alpha: 1.0))
    static var red = Gradient(dark: Color(red: 200/255.0, green: 53/255.0, blue: 52/255.0, alpha: 1.0), light: Color(red: 200/255.0, green: 53/255.0, blue: 52/255.0, alpha: 1.0))
    static var purple = Gradient(dark: Color(red: 75/255.0, green: 35/255.0, blue: 141/255.0, alpha: 1.0), light: Color(red: 203/255.0, green: 138/255.0, blue: 248/255.0, alpha: 1.0))
    static var pink = Gradient(dark: Color(red: 237/255.0, green: 108/255.0, blue: 112/255.0, alpha: 1.0), light: Color(red: 238/255.0, green: 125/255.0, blue: 98/255.0, alpha: 1.0))
    
    var index: Int {
        if let index = Gradient.gradients.firstIndex(of: self) {
            return index
        }
        fatalError("Gradient is not found inside gradients array.")
    }
    
    var darkColor: UIColor {
        return UIColor(color: dark)
    }
    
    var lightColor: UIColor {
        return UIColor(color: light)
    }
    
    private var dark: Color
    private var light: Color
    
}

private struct Color: Codable {
    
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
}

fileprivate extension UIColor {
    
    convenience init(color: Color) {
        self.init(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
    
}
