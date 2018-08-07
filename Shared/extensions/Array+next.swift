//
//  Array+next.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

extension Array {
    
    func next(startingAt index: Int) -> Element {
        if index + 1 < count {
            return self[index + 1]
        }
        return first!
    }
    
    func previous(startingAt index: Int) -> Element {
        if index - 1 < 0 {
            return last!
        }
        return self[index - 1]
    }
    
}
