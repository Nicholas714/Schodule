//
//  Array+remove.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func remove(element: Element?) {
        if let element = element, let removeIndex = firstIndex(of: element) {
            remove(at: removeIndex)
        }
    }
    
}
